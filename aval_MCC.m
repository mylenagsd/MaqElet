clc
close all
clear 

load MCC_mag.dat
if_values = MCC_mag(:,1);
ea_values = MCC_mag(:,2);
n_0 = 1200;

%Input
prompt = {'1 - Exc. Independente, 2 - Em Derivação, 3 - Série, 4 - Composto'};
dlgtitle = 'Input: Qual tipo do Motor CC';
dims = [1 45];
definput = {'1'};
answer = inputdlg(prompt,dlgtitle,dims,definput);

tipo =  str2num(answer{1});
Pnom = 30; %HP
Vt = 240; %V
nnom = 1800; %rpm
nm0 = 1200; %rpm
Ra = 0.19; %Ohm
Rs = 0.02; %Ohm
Inom = 110; %A
Nf = 2700; %esp/polo
Nse = 14; %esp/polo
Rf = 75; %Ohm
Raj = 100; %a 400 %Ohm
Prot = 3550; %W plena carga

%Q1
Raj = 175; %para Q1
Ea1 = Vt; %para Q1
if tipo == 1 %derivação
    If1 = Vt/(Raj + Rf);
    Ea0 = interp1(if_values,ea_values,If1); %pega Ea0 do grafico;
    nm1 = (Ea1/Ea0)*nm0;
elseif tipo == 2 %exc. independente
    If1 = Vt/(Raj + Rf);
    Ea0 = interp1(if_values,ea_values,If1); %pega Ea0 do grafico;
    nm1 = (Ea1/Ea0)*nm0;
elseif tipo == 3 %serie
    Ea0 = Vt - Il*(Ra + Rs); %pega Ea0 do grafico;
    nm1 = (Ea1/Ea0)*nm0;
elseif tipo == 4 %composto
    If1 = Vt/(Raj + Rf); %Ia = 0
    Ea0 = interp1(if_values,ea_values,If1); %pega Ea0 do grafico;
    nm1 = (Ea1/Ea0)*nm0;
else
    warndlg('Entrada Inválida para o Tipo de motor'); 
    return
end

%Q2
Il = Inom; %para Q2
if tipo == 1 %derivação
    If2 = If1; %de Q1
    Ia = Il - If2;
    Ea2 = Vt - Ia*Ra; %Ea a plena carga
    Ea0 = interp1(if_values,ea_values,If2); %pega Ea0 do grafico;
    nm2 = (Ea2/Ea0)*nm0;
    RV = ((nm1 - nm2)/nm2)*100;
elseif tipo == 2 %exc. independente
    If2 = If1; %de Q1
    Ia = Il;
    Ea2 = Vt - Ia*Ra; %Ea a plena carga
    Ea0 = interp1(if_values,ea_values,If2); %pega Ea0 do grafico;
    nm2 = (Ea2/Ea0)*nm0;
    RV = ((nm1 - nm2)/nm2)*100;
elseif tipo == 3 %serie
    nm2 = nm0;
    RV = ((nm1 - nm2)/nm2)*100;
elseif tipo == 4 %composto
    If2 = If1; %de Q1
    Ia = Il - If2;
    Ea2 = Vt - Ia*(Ra + Rs); %Ea a plena carga
    If2 = If1 + (Nse/Nf)*Ia;
    Ea0 = interp1(if_values,ea_values,If2); %pega Ea0 do grafico;
    nm2 = (Ea2/Ea0)*nm0;
    RV = ((nm1 - nm2)/nm2)*100;
else
    warndlg('Entrada Inválida para o Tipo de motor'); 
    return
end



%Q3
Raj = 250; %para Q3
if tipo == 1 %derivação
    If3 = Vt/(Raj + Rf);
    Ea3 = Ea2; %Ea mantem a plena carga
    Ea0 = interp1(if_values,ea_values,If3); %pega Ea0 do grafico;
    nm3 = (Ea3/Ea0)*nm0;
elseif tipo == 2 %exc. independente
    If3 = Vt/(Raj + Rf);
    Ea3 = Ea2; %Ea mantem a plena carga
    Ea0 = interp1(if_values,ea_values,If3); %pega Ea0 do grafico;
    nm3 = (Ea3/Ea0)*nm0;
elseif tipo == 3 %serie
    %Ea3 = Vt - Il*(Ra + Rs);
    %Ea0 = Vt - Il*(Ra + Rs);
    %nm3 = (Ea3/Ea0)*nm0;
elseif tipo == 4 %composto
    If3 = Vt/(Raj + Rf);
    Ia = Il - If3;
    Ea3 = Vt - Ia*(Ra + Rs); %Ea a plena carga
    If3 = Vt/(Raj + Rf) + (Nse/Nf)*Ia;
    Ea0 = interp1(if_values,ea_values,If3); %pega Ea0 do grafico;
    nm3 = (Ea3/Ea0)*nm0;
else
    warndlg('Entrada Inválida para o Tipo de motor'); 
    return
end
%Raj aumenta, Wn aumenta

%Q4 
Fra0 = 1000; %Ae %para Q4
If4 = If2; %para Raj = 175 Ohm %de Q2
if tipo == 1 %derivação
    If4_ra = If4 - (Fra0/Nf);
    Ea0 = interp1(if_values,ea_values,If4_ra); %pega Ea0 do grafico;
    Ea4 = Ea2; %Ea a plena carga %de Q2
    nm4 = (Ea4/Ea0)*nm0;
elseif tipo == 2 %exc. independente
    If4_ra = If4 - (Fra0/Nf);
    Ea0 = interp1(if_values,ea_values,If4_ra); %pega Ea0 do grafico;
    Ea4 = Ea2; %Ea a plena carga %de Q2
    nm4 = (Ea4/Ea0)*nm0;
elseif tipo == 3 %serie
    %If4_ra = If4 - (Fra0/Nf);
    %Ea0 = interp1(if_values,ea_values,If4_ra); %pega Ea0 do grafico;
    %Ea4 = Ea2; %Ea a plena carga %de Q2
    %nm4 = (Ea4/Ea0)*nm0;
elseif tipo == 4 %composto
    Ia4 = Il - If4;
    If4_ra = If4 + (Nse/Nf)*Ia4 - (Fra0/Nf);
    Ea0 = interp1(if_values,ea_values,If4_ra); %pega Ea0 do grafico;
    Ea4 = Ea2; %Ea a plena carga %de Q2
    nm4 = (Ea4/Ea0)*nm0;
else
    warndlg('Entrada Inválida para o Tipo de motor'); 
    return
end
%com R.A., Wm*>Wm

%Q5
figure
if tipo == 1 %derivação
    for i = 1:1:8
        Raj5(i) = 100+25*(i-1);
        Ea5 = Vt; %para Q5
        If5(i) = Vt/(Raj5(i) + Rf);
        %pega Ea0 do grafico;
        Ea05(i) = interp1(if_values,ea_values,If5(i));
        nm5(i) = (Ea5/Ea05(i))*nm0;
        hold on
        plot(If5,nm5);
    end
    hold off
    xlabel('Corrente de campo If') 
    ylabel('Velocidade de rotação')
    title('Motor CC em Derivação');
elseif tipo == 2 %exc. independente
    for i = 1:1:8
        Raj5(i) = 100+25*(i-1);
        Ea5 = Vt; %para Q5
        If5(i) = Vt/(Raj5(i) + Rf);
        Ea05(i) = interp1(if_values,ea_values,If5(i)); %pega Ea0 do grafico;
        nm5(i) = (Ea5/Ea05(i))*nm0;
        hold on
        plot(If5,nm5);
    end
    hold off
    xlabel('Corrente de campo If') 
    ylabel('Velocidade de rotação')
    title('Motor CC de Excitação Independente');
elseif tipo == 3 %serie
    %for i = 1:1:8
    %    Raj5(i) = 100+25*(i-1);
    %    Ea5 = Vt; %para Q5
    %    If5(i) = Inom;
    %    Ea05(i) = interp1(if_values,ea_values,If5(i)); %pega Ea0 do grafico;
    %    nm5(i) = (Ea5/Ea05(i))*nm0;
    %    hold on
    %    plot(If5,nm5);
    %end
    %hold off
    %xlabel('Corrente de campo If') 
    %ylabel('Velocidade de rotação')
    %title('Motor CC Série');
elseif tipo == 4 %composto
    for i = 1:1:8
        Raj5(i) = 100+25*(i-1);
        Ea5 = Vt; %para Q5
        If5(i) = Vt/(Raj5(i) + Rf);
        Ia = Il - If5(i); 
        If5(i) = Vt/(Raj5(i) + Rf) + (Nse/Nf)*Ia;
        Ea05(i) = interp1(if_values,ea_values,If5(i)); %pega Ea0 do grafico;
        nm5(i) = (Ea5/Ea05(i))*nm0;
        hold on
        plot(If5,nm5);
    end
    hold off
    xlabel('Corrente de campo If') 
    ylabel('Velocidade de rotação')
    title('Motor CC Composto');
else
    warndlg('Entrada Inválida para o Tipo de motor'); 
    return
end

%Q6
Fra0 = 1200; %Questao 6 pede 1200
Il = 0:1:110;
if tipo == 1 %derivação
    Ia = Il - If1; %da Q1
    Ea = Vt - Ia*Ra;
    Fra = (Ia/110)*Fra0; %Coloquei 110 considerando o exemplo 8-2
    If_ra = If1 - Fra/Nf;
    If = If1;
    Ea0_ra = interp1(if_values,ea_values,If_ra);
    Ea0 = interp1(if_values,ea_values,If);
    nm_ra = (Ea./Ea0_ra)*nm0;
    nm = (Ea./Ea0)*nm0;
    Tind_ra = Ea.*Ia./(nm_ra*2*pi/60);
    Tind = Ea.*Ia./(nm*2*pi/60);
elseif tipo == 2 %exc. independente
    Ia = Il - If1; %da Q1
    Ea = Vt - Ia*Ra;
    Fra = (Ia/110)*Fra0; %Coloquei 110 considerando o exemplo 8-2
    If_ra = If1 - Fra/Nf;
    If = If1;
    Ea0_ra = interp1(if_values,ea_values,If_ra);
    Ea0 = interp1(if_values,ea_values,If);
    nm_ra = (Ea./Ea0_ra)*nm0;
    nm = (Ea./Ea0)*nm0;
    Tind_ra = Ea.*Ia./(nm_ra*2*pi/60);
    Tind = Ea.*Ia./(nm*2*pi/60);
elseif tipo == 3 %serie
    %resolver passos anteriores
elseif tipo == 4 %composto
    Ia = Il - If1; %da Q1
    Ea = Vt - Ia*(Ra + Rs);
    Fra = (Ia/110)*Fra0;
    If_ra = If1 + (Nse/Nf)*Ia - Fra/Nf;
    If = If1 + (Nse/Nf)*Ia;
    Ea0_ra = interp1(if_values,ea_values,If_ra);
    Ea0 = interp1(if_values,ea_values,If);
    nm_ra = (Ea./Ea0_ra)*nm0;
    nm = (Ea./Ea0)*nm0;
    Tind_ra = Ea.*Ia./(nm_ra*2*pi/60);
    Tind = Ea.*Ia./(nm*2*pi/60);
else
    warndlg('Entrada Inválida para o Tipo de motor'); 
    return
end
figure
plot(Tind,nm);
hold on;
plot(Tind_ra,nm_ra,'--');
xlabel('\bf\tau_{ind} (N-m)');
ylabel('\bf\itn_{m} \rm\bf(r/min)');
%title ('\bfShunt DC Motor Torque-Speed Characteristic');
legend('Sem reação de armadura','Com reação de armadura');
axis([ 0 225 800 1600]);
grid on;
hold off; 

%Tabela resumo
figure;
dat =  {'Vel. de Rot','Vel. de Rot','Vel. de Rot','Vel. de Rot';...
        nm1,nm2,nm3,nm4;...
        '-','Reg. de Vel.','-','-';...
        '-',RV,'-','-';};
columnname =   {'Q1','Q2','Q3','Q4'};
columnformat = {'numeric','numeric','numeric','numeric'}; 
uitable('Units','normalized','Position',...
            [0.05 0.05 0.755 0.87], 'Data', dat,... 
            'ColumnName', columnname,...
            'ColumnFormat', columnformat,...
            'RowName',[]);
       