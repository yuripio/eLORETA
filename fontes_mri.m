%% Desenvolvido por Yuri Pio Macedo durante pesquisa no laboratório de engenharia biomédica (Biolab) da UFU
%% Aplicação do método e resultados obtidos podem ser encontrados no documento do trabalho de conclusão de curso defendido em 05 de Agosto de 2026
%% 	https://repositorio.ufu.br/handle/123456789/49522

function fontes_mri(EEG, source)
    % project sources on MRI and plot solution
    mri = load('-mat', EEG.dipfit.mrifile);
    mri = ft_volumereslice([], mri.mri);

    cfg              = [];
    cfg.downsample   = 2;
    cfg.parameter    = 'pow';
    source.oridimord = 'pos';
    source.momdimord = 'pos';
    sourceInt  = ft_sourceinterpolate(cfg, source , mri);

    cfg              = [];
    cfg.method       = 'slice';
    cfg.funparameter = 'pow';
    ft_sourceplot(cfg, sourceInt);
end