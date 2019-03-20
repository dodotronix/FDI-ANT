%
% Generic PRBS generator (order 3 up to 13)
%
% -- S = prbs_gen(order, prbs_length, seed)
%      returns pseudorandom bit sequence (PRBS) <-1, 1>
%
% -- PAREMETRS
%      * order      : LFSR order 
%      * seed       : start value in register  
%      *prbs_length : length of generated prbs
%                   _____________
%          seed -->|             |
%         order -->|    PRBS     |--> prbs
%   prbs_length -->|  GENERATOR  |
%                  |_____________|
%
% need below package for proper working
% pkg load communications
%

function prbs = prbs_gen(order, prbs_length, seed) 

  if ~exist('prbs_length')
    prbs_length = (2^order)-1;
  end

  if ~exist('seed')
    seed = prbs_length;
  elseif(seed > prbs_length)
    error('Seed value exceeds maximal number of LFSR.')
  end

  switch (order)
    case  3 taps = [3,2];
    case  4 taps = [4,3];
    case  5 taps = [5,3];
    case  6 taps = [6,5];
    case  7 taps = [7,6];
    case  8 taps = [8,6,5,4];
    case  9 taps = [9,5];
    case 10 taps = [10,7];
    case 11 taps = [11,9];
    case 12 taps = [12,11,8,6];
    case 13 taps = [13,12,10,9];
    otherwise error('PRBS order (%d) not supported. Please select PRBS order in range from 3 to 13.',order);
  end;

  prbs = zeros(1, prbs_length);
  seed = de2bi(seed);
  lfsr_reg =  [seed zeros(1, order-length(seed))];

  for i = 1:prbs_length
    prbs(i) = mod(sum(lfsr_reg(taps)),2);
    lfsr_reg = [prbs(i), lfsr_reg(1:end-1)];
  end
  
  % offset data 0.5 down
  prbs = 2*(prbs-1/2);

endfunction
