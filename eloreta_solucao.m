%% Desenvolvido por Yuri Pio Macedo durante pesquisa no laboratório de engenharia biomédica (Biolab) da UFU
%% Aplicação do método e resultados obtidos podem ser encontrados no documento do trabalho de conclusão de curso defendido em 05 de Agosto de 2026
%% 	https://repositorio.ufu.br/handle/123456789/49522

function eloreta_solucao(source, lat)
    % 1. IDENTIFICAR O ÍNDICE DO TEMPO DA LATÊNCIA ALVO
    [~, idx_lat] = min(abs(source.time - lat));
    
    % 2. EXTRAIR A POTÊNCIA VOLUMÉTRICA DO ELORETA
    if isfield(source, 'avg') && isfield(source.avg, 'pow')
        potencia = source.avg.pow(:, idx_lat);
    else
        error('Campo source.avg.pow ausente! O eLORETA não calculou a potência.');
    end
    
    % Mostra valor original do pico no terminal
    [maxval, maxidx] = max(potencia);
    fprintf('Potência Original (Volume): min=%.4f, max=%.4f\n', min(potencia), maxval);
    fprintf('Vértice de pico volumétrico: #%d\n', maxidx);
    
    % 3. TRANSFORMAÇÃO MATEMÁTICA
    % Normaliza o vetor de potência entre 0 e 1
    pot_min = min(potencia);
    pot_max = max(potencia);
    pot_norm = (potencia - pot_min) ./ (pot_max - pot_min);
    
    % Eleva à potência 2.5 para suprimir o espalhamento e afinar o pico
    pot_transformada = pot_norm .^ 2.5;
    
    % Injeta o resultado transformado em uma estrutura temporária para plotagem
    source_plot = source;
    source_plot.avg.pow(:, idx_lat) = pot_transformada;
    
    % 4. RENDERIZAÇÃO 3D NA SUPERFÍCIE
    [~, ftPath] = ft_version;
    cortex_path = fullfile(ftPath, 'template', 'sourcemodel', 'cortex_8196.surf.gii');
    
    cfg = [];
    cfg.method         = 'surface';
    cfg.funparameter   = 'pow';
    cfg.maskparameter  = 'pow';
    cfg.surffile       = cortex_path;
    cfg.latency        = lat;
    cfg.opacitylim     = [0.15 1]; % Mascara valores baixos de ativação
    cfg.funcolormap    = 'turbo';  % Mapa de cores customizado
    
    % Configuração de ambiente gráfico de alto contraste (Dark Mode)
    figure('Name', 'Solução eLORETA 3D', 'Color', 'k'); 
    ft_sourceplot(cfg, source_plot);
    
    % Ajusta título e estética da janela
    title(sprintf('Ativação Cortical eLORETA (t = %.3f s)', lat), 'Color', 'w', 'FontSize', 12);
    set(gcf, 'Color', 'k');
    set(gca, 'Color', 'k');
end