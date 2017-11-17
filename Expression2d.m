classdef Expression2d < handle
    properties
        array;
    end
    methods
        % constructor
        function obj = Expression2d(varargin)
            % generate 0 2D expression Expression2d(m, n)
            if length(varargin)==2 && isnumeric(varargin{1}) && isnumeric(varargin{2})
                array_temp(varargin{1}, varargin{2}) = Expression;
                obj.array = array_temp;
                for i = 1 : varargin{1}
                    for j = 1 : varargin{2}
                        obj.array(i, j) = Expression(0);
                    end
                end
            % generate from 2D array
            elseif length(varargin) == 1
                % generate from numeric array
                if isnumeric(varargin{1})
                    numeric_array = varargin{1};
                    [m, n] = size(numeric_array);
                    obj.array(m, n) = Expression;
                    for i = 1 : m
                        for j = 1 : n
                            % change every numeric element into Expression object 
                            obj.array(i, j) = Expression(numeric_array(i, j));
                        end
                    end
                % generate from Expression object array (no type check, tbd)
                else
                    obj.array = varargin{1};
                end
            % empty 2D Expression
            elseif isempty(varargin)
                obj.array = [];
            end
        end
        % size()
        function out = dimension(obj, varargin)
            [m, n] = size(obj.array);
            if isempty(varargin)
                out = [m, n];
            elseif length(varargin)==1
                if varargin{1}==1
                    out = m;
                elseif varargin{1}==2
                    out = n;
                end
            end
        end
        % override a + b
        function sum = plus(a, b)
            if a.dimension(1)==b.dimension(1) && a.dimension(2)==b.dimension(2)
                m = a.dimension(1);
                n = a.dimension(2);
                sum(m, n) = Expression;
                a_array = a.array;
                b_array = b.array;
                for i = 1 : m
                    for j = 1 : n
                        sum(i, j) = a_array(i, j) + b_array(i, j);
                    end
                end
                sum = Expression2d(sum);
            else
                disp('dimension mismatch')
            end
        end
        % override a - b
        function diff = minus(a, b)
            diff = a + (-b);
        end
        % override -a
        function neg = uminus(a)
            m = a.dimension(1);
            n = a.dimension(2);
            neg(m, n) = Expression;
            a_array = a.array;
            for i = 1 : m
                for j = 1 : n
                    neg(i, j) = -a_array(i, j);
                end
            end
            neg = Expression2d(neg);
        end
        % override size()
        function varargout = size(obj, varargin)
            [m, n] = size(obj.array);
            if isempty(varargin)
                varargout{1} = m;
                varargout{2} = n;
            elseif length(varargin)==1
                if varargin{1}==1
                    varargout{1} = m;
                elseif varargin{1}==2
                    varargout{1} = n;
                end
            end
        end
        % override number multiplication, only support 1 scalar times a
        % matrix
        function prod = times(a, b)
            if isnumeric(a)
                [m, n] = size(a);
                [p, q] = size(b);
                if m==1 && n==1
                    prod_array(p, q) = Expression; 
                    for i = 1 : p
                        for j = 1 : q
                            prod_array(i, j) = a .* b.pop(i, j);
                        end
                    end
                    prod = Expression2d();
                    prod.array = prod_array;
                else
                    disp('dimension mismatch');
                end
            elseif isnumeric(b)
                [m, n] = size(a);
                [p, q] = size(b);
                if p==1 && q==1
                    prod_array(m, n) = Expression; 
                    for i = 1 : m
                        for j = 1 : n
                            prod_array(i, j) = a.pop(i, j) .* b;
                        end
                    end
                    prod = Expression2d();
                    prod.array = prod_array;
                else
                    disp('dimension mismatch');
                end
            end
        end                 
        % override matrix multiplication a * b
        function prod = mtimes(a, b)
            % check dimensions
            [m, n] = size(a);
            [p, q] = size(b);
            if ~(n==p)
                disp('dimension mismatch')
                return
            end
            % empty capacitor of result
            prod = Expression2d(m, q);
            % row of a
            for i = 1 : m
                ref_s.subs = {i, ':'};
                ref_s.type = '()';
                row = a.subsref(ref_s);
                % column of b
                for j = 1 : q
                    ref_s.subs = {':', j};
                    column = b.subsref(ref_s);
                    element = Expression();
                    % row * column
                    for k = 1 : n
                        row_array = row.array;
                        column_array = column.array;
                        temp = row_array(1, k) .* column_array(k, 1);
                        element = element + temp;
                    end
                    % fill capacitor
                    prod.array(i, j) = element;
                end
            end 
        end
        % override sub index assignment b = a(i, j)    
        function obj = subsasgn(obj, s, new)
            if strcmp(s.type, '()')
                m = s.subs{1};
                n = s.subs{2};
                if isa(new, 'Expression')
                    obj.array(m, n) = new;
                else
                    obj.array(m, n) = Expression(new);
                end
            end
        end  
        % override sub index a(i, j)
        function varargout = subsref(obj, s)
            if length(s)==1
                if strcmp(s.type, '()')
                    if isnumeric(s.subs{1})
                        m_num = s.subs{1};
                        m = s.subs{1};
                    elseif strcmp(s.subs{1}, ':')
                        m_num = size(obj.array, 1);
                        m = 1:m_num;
                    end
                    if isnumeric(s.subs{2})
                        n_num = s.subs{2};
                        n = s.subs{2};
                    elseif strcmp(s.subs{2}, ':')
                        n_num = size(obj.array, 2);
                        n = 1:n_num;
                    end
                    element = Expression2d(m_num, n_num);
                    element.array = obj.array(m, n);
                elseif strcmp(s.type, '.')
                    element = obj.(s.subs);
                end
                varargout{1} = element;
            % this guarantees method call
            else 
                varargout = {builtin('subsref',obj,s)};
            end
        end
        % string representation
        function cell_for_disp = expr2str(obj)
            expr_array = obj.array;
            [m, n] = size(expr_array);
            cell_for_disp = cell(m, n);
            for i = 1 : m
                for j = 1 : n
                    element = expr_array(i, j);
                    cell_for_disp{i, j} = element.expr2str();
                end
            end
        end        
        % override output(no ;)
        function display(obj)
            disp(obj.expr2str());
        end
        % get array(m, n) in the form of a Expression object
        function element = pop(obj, varargin)
            if isempty(varargin)
                element = obj.array(1, 1);
            elseif length(varargin)==2
                element = obj.array(varargin{1}, varargin{2});
            else
                element = NaN;
                disp('2 index needed');
            end
        end
    end
end
            