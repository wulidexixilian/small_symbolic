% 1 dimensional expression. Following operations are supported:
%    +, 
%    -, 
%    part of * (variable * variable is not supported)
%    combine common terms
%    solve about a selected variable for the equation expression = 0
classdef Expression < handle
    properties
        term;
    end
    
    methods
        % constructor
        function obj = Expression(varargin)
            if isempty(varargin)
                obj.term = [];
            elseif length(varargin) == 1
                para = varargin{1};
                if ischar(para)
                    % reserved for string parsing initialization
                elseif isnumeric(para)
                    obj.term = SingleSymbolTerm(num2str(para));
                else
                    N = length(para);
                    array(1, N) = SingleSymbolTerm;
                    obj.term = array;
                    for i = 1 : N
                        obj.term(i) = para(i);
                    end
                end
                obj.simplify();
            end
        end
        % combine common symbols
        function obj = simplify(obj)
            % combine common terms
            i = 1;
            while true
                a_term = obj.term(i);
                all_term = obj.term(i+1:end);
                common_idx = i + find(strcmp({all_term.symbol}, a_term.symbol));
                common = obj.term(common_idx);
                for j = 1 : length(common)
                    obj.term(i) = obj.term(i) + common(j);
                end
                obj.term(common_idx) = [];
                i = i + 1;
                if i>length(obj.term)-1
                    break;
                end
            end
            % set all 0 term to be const
            for i = 1 : length(obj.term)
                element = obj.term(i);
                if element.coeff == 0
                    element.symbol = '_CONST';
                    obj.term(i) = element;
                end
            end
            % delete 0 term unless it is the only term left
            i = 1;
            while true
                element = obj.term(i);
                if element.coeff == 0 
                    if length(obj.term)>1
                        obj.term(i) = [];
                    end
                end
                i = i + 1;
                if i>length(obj.term)
                    break;
                end
            end
        end
        % override a + b
        function sum = plus(a, b)
            if isa(a, 'Expression') && isa(b, 'Expression')
                sum = Expression();
                sum.term = [a.term, b.term];
            else
                if isnumeric(a)
                    a = Expression(SingleSymbolTerm(num2str(a)));
                end
                if isnumeric(b)
                    b = Expression(SingleSymbolTerm(num2str(b)));
                end
                if isa(a, 'SingleSymbolTerm')
                    a = Expression(a);
                end
                if isa(b, 'SingleSymbolTerm')
                    b = Expression(b);
                end 
                sum = Expression();
                sum.term = [a.term, b.term];
            end
            sum.simplify();
        end
        % override k .* x
        function prod = times(a, b)
            prod = Expression();
            if isnumeric(a)
                N = length(b.term);
                prod_temp(1, N) = SingleSymbolTerm;
                for i = 1 : N
                    prod_temp(i) = a .* b.term(i);
                end
            elseif isnumeric(b)
                N = length(a.term);
                prod_temp(1, N) = SingleSymbolTerm;
                for i = 1 : N
                    prod_temp(i) = b .* a.term(i);
                end     
            elseif isa(a, 'Expression') && isa(b, 'Expression')
                M = length(a.term);
                N = length(b.term);
                prod_temp(1, M*N) = SingleSymbolTerm;
                for i = 1:M
                    for j = 1:N
                        prod_temp((i-1)*N + j) = a.term(i) .* b.term(j);
                    end
                end
            end
            prod.term = prod_temp;
            prod.simplify();
        end
        % override -a
        function neg = uminus(a)
            neg = -1 .* a;
        end
        % override +a
        function pos = uplus(a)
            pos = a;
        end
        % overide a-b
        function diff = minus(a, b)
            diff = a + (-b);
        end
        % overide [a, b, ...]
        function array = horzcat(varargin)
            m = length(varargin{1});
            n = length(varargin);
            array = Express2d(m, n);
            for i = 1 : m
                column = varargin{i};
                for j = 1 : n
                    array(i, j) = column{j};
                end
            end
        end    
        % overide [a; b; ...]
        function array = vertcat(varargin)
            m = length(varargin);
            n = length(varargin{1});
            array = Express2d(m, n);
            for i = 1 : m
                row = varargin{i};
                for j = 1 : n
                    array(i, j) = row{j};
                end
            end
        end          
        % get coefficients
        function value = coeff(obj, str_symbol)
            all_symbols = [obj.term.symbol];
            coefficients = [obj.term.coeff];
            value = coefficients(strcmp(all_symbols, str_symbol));
        end
        
        function str_out = expr2str(obj)
            if strcmp(obj.term(1).symbol, '_CONST')
                first = num2str(obj.term(1).coeff);
            else
                first = [num2str(obj.term(1).coeff), obj.term(1).symbol];
            end            
            if length(obj.term)>1
                rest = [];
                for i = 2 : length(obj.term)
                    if strcmp(obj.term(i).symbol, '_CONST')
                        next = num2str(obj.term(i).coeff);
                    else
                        next = [num2str(obj.term(i).coeff), obj.term(i).symbol];
                    end
                    if obj.term(i).coeff >= 0
                        rest = [rest, '+', next];
                    else
                        rest = [rest, next];
                    end
                end
                str_out = [first, rest];
            else
                str_out = first;
            end
        end
        % override no ;
        function display(obj)
            disp(obj.expr2str());
        end
        % solve expr = 0
        function solution = solve(obj, var)
            obj.simplify();
            all_symbol = {obj.term.symbol};
            all_coeff = [obj.term.coeff];
            idx = find(strcmp(all_symbol, var));
            solution_symbol = all_symbol;
            solution_symbol(idx) = [];
            solution_coeff = all_coeff;
            solution_coeff(idx) = [];
            solution_coeff = -solution_coeff / all_coeff(idx);
            solution_array(1, length(solution_coeff)) = SingleSymbolTerm;
            for i = 1 : length(solution_coeff)
                solution_array(i) = SingleSymbolTerm(solution_coeff(i), solution_symbol{i});
            end
            solution = Expression(solution_array);
        end          
    end
end
        
        