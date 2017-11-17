classdef SingleSymbolTerm < handle
    properties
        symbol;
        coeff;
    end
    methods
        % constructor
        function obj = SingleSymbolTerm(varargin)
            if isempty(varargin)
                obj.symbol = NaN;
                obj.coeff = 0;
            elseif length(varargin) == 1
                str = varargin{1};
                if isstrprop(str(1), 'alpha')
                    obj.symbol = str;
                    obj.coeff = 1;
                else
                    not_a_const = 0;
                    for i = 1 : length(str)
                        value = str2double(str(1:i));
                        if isnan(value)
                            not_a_const = 1;
                            break
                        end
                    end
                    if i == 1 && not_a_const
                        disp('error, illegal symbol name')
                    else
                        if not_a_const
                            obj.coeff = str2double(str(1:i-1));
                            obj.symbol = str(i:end);
                        else
                            obj.coeff = str2double(str);
                            obj.symbol = '_CONST';
                        end 
                    end % if the first one is not a number
                end % if str is alphabeta
            elseif length(varargin) == 2
                obj.coeff = varargin{1};
                obj.symbol = varargin{2};
            end % if vargin
        end % function
        % check if the term is a const
        function status = isconst(obj)
            if strcmp(obj.symbol, '_CONST')
                status = 1;
            else
                status = 0;
            end
        end
        % override plus a + b
        function sum = plus(a, b)
            if isa(a, 'SingleSymbolTerm') && isa(b, 'SingleSymbolTerm')
                if a.symbol ~= b.symbol
                    sum = Expression([a, b]);
                else
                    sum = SingleSymbolTerm();
                    sum.symbol = a.symbol;
                    sum.coeff = a.coeff + b.coeff;
                end
            else
                if isnumeric(a)
                    a = SingleSymbolTerm(num2str(a));
                end
                if isnumeric(b)
                    b = SingleSymbolTerm(num2str(b));
                end
                sum = Expression({a, b});
            end % if the same symbol
        end % function
        % override uni minus -a
        function neg = uminus(a)
            neg = SingleSymbolTerm();
            neg.symbol = a.symbol;
            neg.coeff = -a.coeff;
        end
        % override uni plus +a
        function pos = uplus(a)
            pos = SingleSymbolTerm();
            pos.symbol = a.symbol;
            pos.coeff = a.coeff;
        end
        % override minus a - b
        function diff = minus(a, b)
            diff = a + (-b);
        end
        % override scalar multiply k .* x
        function prod = times(a, b)
            if isa(a, 'SingleSymbolTerm') && isnumeric(b)
                x = a;
                k = b;
            elseif isa(b, 'SingleSymbolTerm') && isnumeric(a)
                x = b;
                k = a;
            elseif isa(a, 'SingleSymbolTerm') && isa(b, 'SingleSymbolTerm') &&...
                    a.isconst()
                x = b;
                k = a.coeff;
            elseif isa(a, 'SingleSymbolTerm') && isa(b, 'SingleSymbolTerm') &&...
                    b.isconst()
                x = a;
                k = b.coeff;
            else
                disp('type error')
                return
            end
            prod = SingleSymbolTerm();
            prod.coeff = k * x.coeff;
            prod.symbol = x.symbol;
        end
    end % methods
end
            
                