function [x,Resnorm,FVAL,EXITFLAG,OUTPUT,LAMBDA,JACOB] = lsqncommon(FUN,x,YDATA,LB,UB,options,defaultopt,caller,computeLambda,varargin)
%LSQNCOMMON Solves non-linear least squares problems.
%   [X,RESNORM,RESIDUAL,EXITFLAG,OUTPUT,LAMBDA,JACOBIAN]=...
%      LSQNCOMMON(FUN,X0,YDATA,LB,UB,OPTIONS,DEFAULTOPT,CALLER,COMPUTELAMBDA,XDATA,VARARGIN...) 
%   contains all the setup code common to both LSQNONLIN and LSQCURVEFIT to call either the 
%   large-scale SNLS or the medium-scale NLSQ.
% Check for non-double inputs
if ~isa(x,'double') || ~isa(YDATA,'double') || ~isa(LB,'double') ...
    || ~isa(UB,'double')
  error('optim:lsqncommon:NonDoubleInput', ...                                     
        '%s only accepts inputs of data type double.',upper(caller))       
end

xstart=x(:);
numberOfVariables=length(xstart);
% Note: XDATA is bundled with varargin already for lsqcurvefit 
lenVarIn = length(varargin);

large = 'large-scale';
medium = 'medium-scale';

switch optimget(options,'Display',defaultopt,'fast')
case {'off','none'}
    verbosity = 0;
case 'iter'
    verbosity = 2;
case 'final'
    verbosity = 1;
case 'testing'
    verbosity = Inf;
otherwise
    verbosity = 1;
end

[xstart,l,u,msg] = checkbounds(xstart,LB,UB,numberOfVariables);
if ~isempty(msg)
    EXITFLAG = -2;
    [Resnorm,FVAL,LAMBDA,JACOB] = deal([]);
    x(:)=xstart;
    OUTPUT.firstorderopt = [];
    OUTPUT.iterations = 0;
    OUTPUT.funcCount = 0;
    OUTPUT.cgiterations = [];
    OUTPUT.algorithm = ''; % Not known at this stage
    OUTPUT.message = msg;
    if verbosity > 0
        disp(msg)
    end
    return
end
lFinite = ~isinf(l);
uFinite = ~isinf(u);

if min(min(u-xstart),min(xstart-l)) < 0
    xstart = startx(u,l); 
end

diagnostics = isequal(optimget(options,'Diagnostics',defaultopt,'fast'),'on');
gradflag =  strcmp(optimget(options,'Jacobian',defaultopt,'fast'),'on');
line_search = strcmp(optimget(options,'LargeScale',defaultopt,'fast'),'off'); % 0 means large-scale, 1 means medium-scale
funValCheck = strcmp(optimget(options,'FunValCheck',defaultopt,'fast'),'on');
mtxmpy = optimget(options,'JacobMult',[]); % use old
if isequal(mtxmpy,'atamult')
    warning('optim:lsqncommon:FunNameClash', ...
           ['Potential function name clash with a Toolbox helper function:\n' ...
            ' Use a name besides ''atamult'' for your JacobMult function to\n' ...
            ' avoid errors or unexpected results.'])
end

% Convert to inline function as needed
if ~isempty(FUN)  % will detect empty string, empty matrix, empty cell array
    funfcn = lsqfcnchk(FUN,caller,lenVarIn,funValCheck,gradflag);
else
    error('optim:lsqncommon:InvalidFUN',['FUN must be a function handle;\n' ...  
          ' or, FUN may be a cell array that contains function handles.'])
end

fuser = [];  
JAC = [];
x(:) = xstart;
try
    switch funfcn{1}
    case 'fun'
        fuser = feval(funfcn{3},x,varargin{:});
    case 'fungrad'
        [fuser,JAC] = feval(funfcn{3},x,varargin{:});
    case 'fun_then_grad'
        fuser = feval(funfcn{3},x,varargin{:}); 
        JAC = feval(funfcn{4},x,varargin{:});
    otherwise
        error('optim:lsqncommon:UndefCallType','Undefined calltype in %s.',upper(caller))
    end
catch
    if ~(isequal(funfcn{1},'fun_then_grad')) || isempty(fuser)
        badfunfcn = funfcn{3};
    else % 'fun_then_grad & ~isempty(fuser) (so it error'ed out on the JAC call)
        badfunfcn = funfcn{4};
    end   
    if isa(badfunfcn,'inline')
        errmsg = sprintf(['User supplied %s ==> %s\n' ...
                'failed with the following error:\n\n%s'],...
            'expression or inline function',formula(badfunfcn),lasterr);
    else % function (i.e. string name of), function handle, inline function, or other
        % save last error in case call to "char" errors out
        lasterrmsg = lasterr;
        % Convert to char if possible
        try
            charOfFunction = char(badfunfcn);
        catch
            charOfFunction = '';
        end
        if ~isempty(charOfFunction)
            errmsg = sprintf(['User supplied %s ==> %s\n' ...
                    'failed with the following error:\n\n%s'],...
                'function',charOfFunction,lasterrmsg);
        else
            errmsg = sprintf(['User supplied %s ' ...
                    'failed with the following error:\n\n%s'],...
                'function',lasterrmsg);
        end
    end
    error('optim:lsqncommon:InvalidFUN',errmsg)
end

if isequal(caller,'lsqcurvefit')
    if ~isequal(size(fuser), size(YDATA))
        error('optim:lsqncommon:YdataSizeMismatchFunVal','Function value and YDATA sizes are incommensurate.')
    end
    fuser = fuser - YDATA;  % preserve fuser shape until after subtracting YDATA 
end

f = fuser(:);
nfun=length(f);

if gradflag
    % check size of JAC
    [Jrows, Jcols]=size(JAC);
    if isempty(mtxmpy) 
        % Not using 'JacobMult' so Jacobian must be correct size
        if Jrows~=nfun || Jcols ~=numberOfVariables
            error('optim:lsqncommon:InvalidJacSize',['User-defined Jacobian is not the correct size:\n' ...
                     'the Jacobian matrix should be %d-by-%d.'],nfun,numberOfVariables)
        end
    end
else
    Jrows = nfun; 
    Jcols = numberOfVariables;   
end

% trustregion and enough equations (as many as variables) 
if ~line_search && nfun >= numberOfVariables 
    OUTPUT.algorithm = large;
    
    % trust region and not enough equations -- switch to line_search
elseif ~line_search && nfun < numberOfVariables 
    warning('optim:lsqncommon:SwitchToLineSearch', ...
            ['Large-scale method requires at least as many equations as variables;\n' ...
             ' switching to line-search method instead.  Upper and lower bounds will be ignored.'])
    OUTPUT.algorithm = medium;
    
    % line search and no bounds  
elseif line_search && isempty(l(lFinite)) && isempty(u(uFinite))
    OUTPUT.algorithm = medium;
    
    % line search and  bounds  and enough equations, switch to trust region 
elseif line_search && (~isempty(l(lFinite)) || ~isempty(u(uFinite))) && nfun >= numberOfVariables
    warning('optim:lsqncommon:SwitchToLargeScale', ...
            ['Line-search method does not handle bound constraints;\n' ...
             ' switching to large-scale method instead.'])
    OUTPUT.algorithm = large;
    
    % can't handle this one:   
elseif line_search && (~isempty(l(lFinite)) || ~isempty(u(uFinite))) && nfun < numberOfVariables
    error('optim:lsqncommon:ProblemNotHandled', ...
         ['Line-search method does not handle bound constraints\n' ...
          ' and large-scale method requires at least as many\n' ... 
          ' equations as variables; aborting.']);
end

if diagnostics > 0
    % Do diagnostics on information so far
    constflag = 0; gradconstflag = 0; non_eq=0;non_ineq=0;lin_eq=0;lin_ineq=0;
    confcn{1}=[];c=[];ceq=[];cGRAD=[];ceqGRAD=[];
    hessflag = 0; HESS=[];
    msg = diagnose(caller,OUTPUT,gradflag,hessflag,constflag,gradconstflag,...
        line_search,options,defaultopt,xstart,non_eq,...
        non_ineq,lin_eq,lin_ineq,l,u,funfcn,confcn,f,JAC,HESS,c,ceq,cGRAD,ceqGRAD);
end

% Execute algorithm
if isequal(OUTPUT.algorithm,large)
    if ~gradflag % provide sparsity of Jacobian if not provided.
        Jstr = optimget(options,'JacobPattern',[]);
        if isempty(Jstr)  
            % Put this code separate as it might generate OUT OF MEMORY error
            Jstr = sparse(ones(Jrows,Jcols));
        end
        if ischar(Jstr) 
            if isequal(lower(Jstr),'sparse(ones(jrows,jcols))')
                Jstr = sparse(ones(Jrows,Jcols));
            else
                error('optim:lsqncommon:JacobpatternMustBeMatrix', ...
                    'Option ''JacobPattern'' must be a matrix if not the default.')
            end
        end
    else
        Jstr = [];
    end
    [x,FVAL,LAMBDA,JACOB,EXITFLAG,OUTPUT,msg]=...
        snls(funfcn,x,l,u,verbosity,options,defaultopt,f,JAC,YDATA,caller,Jstr,computeLambda,varargin{:});
else
    [x,FVAL,JACOB,EXITFLAG,OUTPUT,msg] = ...
        nlsq(funfcn,x,verbosity,options,defaultopt,f,JAC,YDATA,caller,varargin{:});
    LAMBDA.upper=[]; LAMBDA.lower=[];   
end
Resnorm = FVAL'*FVAL;
OUTPUT.message = msg;
if verbosity > 0
    disp(OUTPUT.message);
end


% Reset FVAL to shape of the user-function, fuser
FVAL = reshape(FVAL,size(fuser));

%--end of lsqncommon--
