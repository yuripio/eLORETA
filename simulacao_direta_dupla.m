%% Desenvolvido por Yuri Pio Macedo durante pesquisa no laboratório de engenharia biomédica (Biolab) da UFU
%% Aplicação do método e resultados obtidos podem ser encontrados no documento do trabalho de conclusão de curso defendido em 05 de Agosto de 2026
%% 	https://repositorio.ufu.br/handle/123456789/49522

function simulacao_direta_dupla(vol, dataAvg)
fprintf('\n=== INICIANDO SIMULAÇÃO DO PROBLEMA DIRETO (2 DIPOLOS) ===\n');

% 1. O CÉREBRO ARTIFICIAL (Fontes Bilaterais)
posicao_alvo_esq = [-40, -25, 50];  % Córtex somatossensorial esquerdo
posicao_alvo_dir = [ 40, -25, 50];  % Córtex somatossensorial direito (espelhado)

cfg = [];
cfg.headmodel = vol.vol;
cfg.elec      = dataAvg.elec;   
% Matriz 2x3: Cada linha é um dipolo
cfg.dip.pos   = [posicao_alvo_esq; posicao_alvo_dir];
% Matriz 3x2: Cada coluna é a força (X, Y, Z) de um dipolo
cfg.dip.mom   = [1 1; 0 0; 0 0];       
cfg.relnoise  = 0.05;           % 50% de ruído branco

dados_simulados = ft_dipolesimulation(cfg);

% 2. O PROBLEMA INVERSO
fprintf('Calculando Covariancia Simulada...\n');
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

% 3. DIAGNÓSTICO MATEMÁTICO DA SEPARAÇÃO ESPACIAL
numVoxels = size(source_sim.pos, 1);
pow_dinamico = zeros(numVoxels, 1);

for i = 1:numVoxels
    if ~isempty(source_sim.avg.mom{i})
        pow_dinamico(i) = sum(source_sim.avg.mom{i}(:, 1).^2); 
    end
end

source_sim.avg.pow = pow_dinamico;

% Como agora temos 2 dipolos, encontrar apenas o valor "max" global não basta.
% Vamos isolar o pico do lado esquerdo e o pico do lado direito matematicamente.
idx_esq = find(source_sim.pos(:,1) < 0); % Voxels com X negativo (Esquerda)
idx_dir = find(source_sim.pos(:,1) > 0); % Voxels com X positivo (Direita)

[~, max_idx_esq_rel] = max(pow_dinamico(idx_esq));
[~, max_idx_dir_rel] = max(pow_dinamico(idx_dir));

coords_esq = source_sim.pos(idx_esq(max_idx_esq_rel), :);
coords_dir = source_sim.pos(idx_dir(max_idx_dir_rel), :);

fprintf('\n=== RESULTADO DA VALIDAÇÃO (2 FONTES) ===\n');
fprintf('Alvo Esq : X=%6.1f, Y=%6.1f, Z=%6.1f | eLORETA Achou: X=%6.1f, Y=%6.1f, Z=%6.1f\n', ...
    posicao_alvo_esq(1), posicao_alvo_esq(2), posicao_alvo_esq(3), ...
    coords_esq(1), coords_esq(2), coords_esq(3));

fprintf('Alvo Dir : X=%6.1f, Y=%6.1f, Z=%6.1f | eLORETA Achou: X=%6.1f, Y=%6.1f, Z=%6.1f\n', ...
    posicao_alvo_dir(1), posicao_alvo_dir(2), posicao_alvo_dir(3), ...
    coords_dir(1), coords_dir(2), coords_dir(3));

% Envia para a plotagem 3D
%eloreta_solucao(source_sim, 0); 
end