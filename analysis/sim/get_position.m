%
% This function do estimation of peaks and find maxima 
%
% -- [y, x] = get_position(signal_in, d, th)
%      returns detected peaks and aproximated position of maxima
%
% -- PARAMETERS:
%      signal_in : signal input 
%              d : distance vector
%             th : threshold (user defined)
%                   ______________
%                  |              |
%                  | get_position |--> [y, x]
%     signal_in -->|              |
%                  |______________|
%
% need below package for proper working
% pkg load signal
%

function [y, x] = get_position(signal_in, d, th, en)
  if(strcmp(en, 'none') || strcmp(en, 'hyper'))
    order = 2;
    right = ceil(order/2);
    left = ceil(order/2);

    [py, px] = findpeaks(signal_in,'DoubleSided','MinPeakHeight', th);
    y = py;
    x = d(px);

    if(strcmp(en, 'hyper'))
      for i = length(px)
        v_y = signal_in(px(i)-left:px(i)+right);
        v_x = d(px(i)-left:px(i)+right);
        % interpolation
        pp = polyfit(v_x, v_y, order);
        rx = roots(polyder(pp))(1);
        x(i) = rx;
        y(i) = polyval(pp, rx);
      end
    end
  end
end
