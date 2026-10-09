%% Desenvolvido por Yuri Pio Macedo durante pesquisa no laboratório de engenharia biomédica (Biolab) da UFU
%% Aplicação do método e resultados obtidos podem ser encontrados no documento do trabalho de conclusão de curso defendido em 05 de Agosto de 2026
%% 	https://repositorio.ufu.br/handle/123456789/49522

function simulacao_direta(vol, dataAvg)
fprintf('\n=== INICIANDO SIMULAÇÃO DO PROBLEMA DIRETO ===\n');

% 1. O CÉREBRO ARTIFICIAL 
% Coordenada MNI do toque no dedo direito (Hemisfério Esquerdo)
posicao_alvo = [-40, -25, 50]; 

cfg = [];
cfg.headmodel = vol.vol;
cfg.elec      = dataAvg.elec;   % Pega SÓ as coordenadas da touca, ignora o sinal real
cfg.dip.pos   = posicao_alvo;
cfg.dip.mom   = [1 0 0]';       % Força do choque artificial
cfg.relnoise  = 0.10;           % Adiciona % de ruído branco para realismo

% CRIA OS DADOS FALSOS AQUI:
dados_simulados = ft_dipolesimulation(cfg);

% 2. O PROBLEMA INVERSO (O eLORETA tenta adivinhar usando os dados falsos)
fprintf('Calculando Covariância Simulada...\n');
cfg = [];
cfg.covariance = 'yes';
cfg.covariancewindow = 'all';
sim_avg = ft_timelockanalysis(cfg, dados_simulados); 

fprintf('Gerando Malha e Leadfield...\n');
cfg = [];
cfg.resolution = 5;
cfg.unit       = 'mm';
cfg.elec       = dados_simulados.elec;
cfg.headmodel  = vol.vol;
sourcemodel    = ft_prepare_sourcemodel(cfg);

cfg = [];
cfg.elec      = dados_simulados.elec;
cfg.headmodel = vol.vol;
cfg.grid      = sourcemodel;
leadfield     = ft_prepare_leadfield(cfg);

fprintf('Rodando eLORETA no dado simulado...\n');
cfg = [];
cfg.method    = 'eloreta';
cfg.headmodel = vol.vol;
cfg.grid      = leadfield;
cfg.eloreta.lambda = 0.05;
source_sim    = ft_sourceanalysis(cfg, sim_avg);

% 3. DIAGNÓSTICO MATEMÁTICO
numVoxels = size(source_sim.pos, 1);
pow_dinamico = zeros(numVoxels, 1);
for i = 1:numVoxels
    if ~isempty(source_sim.avg.mom{i})
        % Simulação tem energia constante, tempo 1
        pow_dinamico(i) = sum(source_sim.avg.mom{i}(:, 1).^2); 
    end
end

[~, maxidx] = max(pow_dinamico);
coords_encontradas = source_sim.pos(maxidx, :);

fprintf('\n=== RESULTADO DA VALIDAÇÃO ===\n');
fprintf('Alvo Original : X=%6.1f, Y=%6.1f, Z=%6.1f\n', posicao_alvo(1), posicao_alvo(2), posicao_alvo(3));
fprintf('eLORETA Achou : X=%6.1f, Y=%6.1f, Z=%6.1f\n', coords_encontradas(1), coords_encontradas(2), coords_encontradas(3));

% Envia para a função de plotagem ortogonal para gerar a imagem 3D
source_sim.avg.pow = pow_dinamico;
eloreta_solucao(source_sim, 0); 
end