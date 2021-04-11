clc
close all
clear

%Input variáveis
prompt = {'Vphi: [V]','Pólos: ','Fator de potência: ','Corrente de entrada: [A]','Conexão: 1-estrela, 2-delta','Frequência de entrada: [Hz]','Perdas enrol. estator: [W]','Perdas enrol. rotor: [W]','Perdas no núcleo: [W]','Perdas rotacionais: [W]'};
dlgtitle = 'Input: Motor de Indução';
dims = [1 50];
definput = {'460','4','0.85','25','1','50','1000','500','800','250'};
answer = inputdlg(prompt,dlgtitle,dims,definput)

%Valores para cálculos iniciais
Vt = str2num(answer{1});
P = str2num(answer{2});
FP = str2num(answer{3});
Il = str2num(answer{4});
conexao = str2num(answer{5});
f_se = str2num(answer{6});
Pce = str2num(answer{7});
Pcr = str2num(answer{8});
Pnuc = str2num(answer{9});
Prot = str2num(answer{10});

%letra a)
if conexao == 1
    Pin = sqrt(3)*Vt*Il*FP;      
elseif conexao == 2
    Pin = 3*Vt*(Il/sqrt(3))*FP;
else
    warndlg('Entrada Inválida para o Tipo de conexão, digite 1 para estrela ou 2 para delta'); 
    return
end
Pef = Pin - Pce - Pnuc;            % <=========

%letra b)
Pconv = Pef - Pcr;                 % <=========

%letra c)
Pout = Pconv - Prot;               % <=========

%letra d)
rendimento = (Pout/Pin)*100;       % <=========

%letra e)
S = 1 - (Pconv/Pef);               % <=========
n_sinc = (120*f_se)/P;
n_m = (1 - S)*n_sinc;              % <=========

%letra f)
w_m = (n_m*2*pi)/60;
Tind = Pconv/w_m;                  % <=========

%letra g)
Tcarga = Pout/w_m;                 % <=========

%Tabela resumo
figure;
dat =  {'Pot. eletromagnética','Pot. mecânica','Pot. de saída','Eficiência','Escorregamento','Torque elet.','Torque no eixo';...
        Pef,Pconv,Pout,rendimento,S,Tind,Tcarga;...
        '-','-','-','-','Vel. do eixo','-','-';...
        '-','-','-','-',n_m,'-','-';};
columnname =   {'a)','b)','c)','d)','e)','f)','g)'};
columnformat = {'numeric','numeric','numeric','numeric','numeric','numeric','numeric'}; 
uitable('Units','normalized','Position',...
            [0.05 0.05 0.755 0.87], 'Data', dat,... 
            'ColumnName', columnname,...
            'ColumnFormat', columnformat,...
            'RowName',[]);