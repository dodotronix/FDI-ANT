%------------------------------------------------------------------------------%
%% Cable frequency dependence

atten = [8.9, 18.4, 27.2, 36.1, 54.8, 74.8, 86.3, 93.8, 174.9];
freq = [10, 50, 100, 200, 400, 700, 900, 1000, 3000];


semilogx(freq, atten, 'linewidth', 3)
xlim([0, 3000])
ylabel('{\Large Útlum [dB / 100 m]}')
xlabel('{\Large Frekvence [MHz]}')

orient('landscape')
h=get(gcf, "currentaxes");
set(h, "fontsize", 16);
grid on

h = legend({'Koaxiální kabel RG316'},'location','northeast');
set (h, "fontsize", 16);

target = '../../../doc/outputs/sim/'
name = 'cable.tex'
name_inc = 'cable-inc.eps'

print(name, '-dtex');

path = strcat(target, name)
path_inc = strcat(target, name_inc)

movefile(name, path)
movefile(name_inc, path_inc)
