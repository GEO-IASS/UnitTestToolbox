% Method to list all the preferences for the current project
function listPrefs

    % Get current project name
    theProjectName = getpref('UnitTest', 'projectName');
    
    validationPrefs = getpref(theProjectName);
    preferenceNames = fieldnames(validationPrefs);
    
    fprintf('\n Current ''%s'' prefs:\n', theProjectName);
    for k = 1:numel(preferenceNames)
        value = validationPrefs.(preferenceNames{k});
        if ischar(value)
            fprintf('\t %-25s : ''%s''\n', sprintf('''%s''', preferenceNames{k}), value);
        elseif islogical(value)
            fprintf('\t %-25s : %s\n', sprintf('''%s''', preferenceNames{k}), logicalToString(value));
        else
            fprintf('\t %-25s : %g\n', sprintf('''%s''', preferenceNames{k}), value);
        end
    end
    fprintf('\n');
end

function str = logicalToString(value)
    if value
        str = 'true';
    else
        str = 'false';
    end
end

