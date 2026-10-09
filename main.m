%% Desenvolvido por Yuri Pio Macedo durante pesquisa no laboratório de engenharia biomédica (Biolab) da UFU
%% Aplicação do método e resultados obtidos podem ser encontrados no documento do trabalho de conclusão de curso defendido em 05 de Agosto de 2026
%% 	https://repositorio.ufu.br/handle/123456789/49522

%% CONVERTER DADOS PARA FORMATO EEGLAB
%% Inicialização
eeglab; close;
eeg_test_all = [];

% Lista de canais na ordem correta pelo padrão 10-10
lista_canais = {'AF7', 'AF3', 'Fp1', 'Fp2', 'AF4', 'AF8', 'F7', 'F5', 'F3', 'F1', ...
                'F2', 'F4', 'F6', 'F8', 'FT7', 'FC5', 'FC3', 'FC1', 'FC2', 'FC4', ...
                'FC6', 'FT8', 'T3', 'C5', 'C3', 'C1', 'C2', 'C4', 'C6', 'T4', 'TP7', ...
                'CP5', 'CP3', 'CP1', 'CP2', 'CP4', 'CP6', 'TP8', 'T5', 'P5', 'P3', ...
                'P1', 'P2', 'P4', 'P6', 'T6', 'Fpz', 'PO7', 'PO3', 'O1', 'O2', ...
                'PO4', 'PO8', 'Oz', 'Fz', 'FCz', 'Cz', 'CPz', 'Pz', 'POz'};

%% INSERIR DADOS
% Insira os caminhos absolutos dos arquivos .mat na lista abaixo.
arquivos = {
    'C:\Arquivo1.mat',
    'C:\Arquivo2.mat'
};

for i = 1:length(arquivos)
    if isfile(arquivos{i})
        % Altere 'segData' se a variável salva no .mat tiver outro nome
        load(arquivos{i}, 'segData');
        
        eeg_temp = converte_eeglab(['EEG_Sujeito_' num2str(i)], segData, lista_canais);
        
        if isempty(eeg_test_all)
            eeg_test_all = eeg_temp;
        else
            eeg_test_all = pop_mergeset(eeg_test_all, eeg_temp);
        end
    else
        warning('Arquivo não encontrado: %s', arquivos{i});
    end
end

eeg_test = eeg_test_all;

%% CALCULAR LATÊNCIA DE FORMA VISUAL
canais_erp = {'Cz', 'CPz', 'Pz', 'POz'};
cores = lines(numel(canais_erp));
figure; hold on;
for i = 1:numel(canais_erp)
    idx = find(strcmp({eeg_test.chanlocs.labels}, canais_erp{i}));
    if ~isempty(idx)
        % Média ao longo dos trials
        erp = mean(squeeze(eeg_test.data(idx,:,:)), 2);  % [tempo]
        plot(eeg_test.times, erp, 'DisplayName', canais_erp{i}, 'Color', cores(i,:));
    end
end
xlabel('Tempo (ms)');
ylabel('Amplitude (µV)');
title('ERP - canais centrais');
legend show;
grid on;

%% RECONSTRUÇÃO ELORETA
% Ajustar valor conforme pico de atividade plotado (padrão está como 300 ms)
[EEG, dataAvg, source, vol] = eloreta_processamento(eeg_test);
eloreta_solucao(source, 0.300);

%% Função para validar posicionamento dos eletrodos no modelo
% figure;
% topoplot([], EEG.chanlocs, 'style', 'blank', 'electrodes', 'labelpoint');
% title('Posicionamento dos Eletrodos');