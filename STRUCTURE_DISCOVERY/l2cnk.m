function [nbits] = l2cnk(n,k)
% $-log_2(1 / C_n^k)$
% log2(n) + log2(n-1) + ... + log2(n-k+1) - 
% log2(k) - log2(k-1) - ... - log2(1)
	nbits = 0;
	for i = n:-1:n-k+1 % n, n-1, ..., n-k+1
		nbits = nbits + log2(i);
	end
	
	for i = k:-1:1 % k, k-1, ..., 1
		nbits = nbits - log2(i);
	end
end
