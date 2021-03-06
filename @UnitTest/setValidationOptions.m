% Method to set certain validation options
function setValidationOptions(obj,varargin)
    
    % parse inputs
    parser = inputParser;
    parser.addParamValue('type',                    obj.validationParams.type,                    @ischar);
    parser.addParamValue('onRunTimeError',          obj.validationParams.onRunTimeErrorBehavior,  @ischar);

    % Execute the parser to make sure input is good
    parser.parse(varargin{:});
    % Copy the parse parameters to the ExperimentController object
    pNames = fieldnames(parser.Results);
    for k = 1:length(pNames)
       obj.validationParams.(pNames{k}) = parser.Results.(pNames{k}); 
    end
    
    % Ensure params have valid values
    checkValidationParams(obj.validationParams);
    
    % Get current project name
    theProjectName = getpref('UnitTest', 'projectName');
    
    % Assemble name of fast validation data directory
    alternateFastDataDir = getpref(theProjectName, 'alternateFastDataDir');
    if (isempty(alternateFastDataDir))
        obj.fastValidationDataDir = fullfile(obj.rootDir, 'data', 'fast', filesep);
    else
        obj.fastValidationDataDir = alternateFastDataDir;
    end

    % Assemble name of full validation data directory
    alternateFullDataDir = getpref(theProjectName, 'alternateFullDataDir');
    if (isempty(alternateFullDataDir))
        obj.fullValidationDataDir = fullfile(obj.rootDir, 'data', 'full', filesep);
    else
        obj.fullValidationDataDir = alternateFullDataDir;
    end
    
    % Use the remote data toolbox?
    useRemoteDataToolbox = getpref(theProjectName, 'useRemoteDataToolbox');
    if (isempty(useRemoteDataToolbox))
        obj.useRemoteDataToolbox = false;
    else
        obj.useRemoteDataToolbox = useRemoteDataToolbox;
    end

    % Configuration for remote data toolbox
    remoteDataToolboxConfig = getpref(theProjectName, 'remoteDataToolboxConfig');
    obj.remoteDataToolboxConfig = remoteDataToolboxConfig;
end

function checkValidationParams(validationParams)
    if (~ismember(validationParams.onRunTimeError, UnitTest.validOnRunTimeErrorValues))
        fprintf(2,'\nValid ''onRunTimeError'' values are:\n');
        for k = 1:numel(UnitTest.validOnRunTimeErrorValues)
            fprintf(2,'''%s''\n', UnitTest.validOnRunTimeErrorValues{k})
        end
        fprintf('\n');
        error('''%s'' is an invalid ''onRunTimeError'' value', validationParams.onRunTimeError);
    end    
    
    if (~ismember(validationParams.type, UnitTest.validValidationTypes))
        fprintf(2,'\nValid validation ''types'' are:\n');
        for k = 1:numel(UnitTest.validValidationTypes)
            fprintf(2,'''%s''\n', UnitTest.validValidationTypes{k})
        end
        fprintf('\n');
        error('''%s'' is an invalid validation type', validationParams.type);
    end
end
