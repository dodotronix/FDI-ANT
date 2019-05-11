%------------------------------------------------------------------------------%
%% Cable frequency dependence

atten = [8.9, 18.4, 27.2, 36.1, 54.8, 74.8, 86.3, 93.8, 174.9];
freq = [10, 50, 100, 200, 400, 700, 900, 1000, 3000];

semilogx(freq, atten, 'linewidth', 2)
xlim([0, 3000])
ylim([0, 180])
ylabel('{Útlum [dB / 100 m]}')
xlabel('{Frekvence [MHz]}')
grid on

orient('landscape')
h = legend({'   koaxiální kabel RG316'},'location','northeast');
set (h, 'fontsize', 20, 'position', [0.14,0.86,0.3,0.06]);
set(gca, 'fontsize', 20,...
    'gridlinestyle', '--',... 
    'minorgridlinestyle', '--',...
    'linewidth', 1,...
    'ytick', [0:15:180]);

%------------------------------------------------------------------------------%
%% plot exporting setups
target = '../../../doc/outputs/sim/'
name = 'cable.tex'
name_inc = 'cable-inc.eps'

print(name, '-dtex');

path = strcat(target, name)
path_inc = strcat(target, name_inc)

movefile(name, path)
movefile(name_inc, path_inc)
