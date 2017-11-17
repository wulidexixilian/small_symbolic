clc;
clear;
x = SingleSymbolTerm('x');
y = SingleSymbolTerm('y');
z = SingleSymbolTerm('z');
e11 = x + y;
e22 = x - 2.*y;
m1 = Expression2d(2,2);
m2 = Expression2d(2,2);
m1(1, 1) = 2;
m1(2, 2) = 0.5;
m2(1, 1) = e11;
m2(2, 2) = e22;
m1
m2
m3 = m1 * m2
m4 = m3 + m2
m5 = m1 - m4
m6 = m1 * (m1 - m2) + m1 * m3
m7 = 3 .* m6
m8 = m7 .* 0.4

expr1 = m6.pop(2, 2);
solution1 = expr1.solve('x')
expr2 = m6.pop(1, 1);
solution2 = expr2.solve('y')
