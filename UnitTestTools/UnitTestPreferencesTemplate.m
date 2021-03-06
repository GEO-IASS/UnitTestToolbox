% Method to set project-specific preferences. Generally, this script should
% be run once only. For different projects, copy this file to the projects' directory
% and adapt the p-struct according to that project's specifics.
%
% You can just run the distributed (Template) version to accept the
% defaults, or you can make a copy outside of the distribution and modify
% for your own system.
%
% To adapt this file to your own project, replace 'theProject', with your project's name
% and similarly for any other fields where 'theProject' appears

function UnitTestPreferencesTemplate

    % Specify root directory.  This is the top level director of the
    % project.
    theProjectRootDir = '/YourDirectory/YourSubdir';
    
    % Specify project-specific preferences
    p = struct(...
            'projectName',           'theProject', ...                                                                                 % The project's name (also the preferences group name)
            'validationRootDir',     fullfile(theProjectRootDir, 'validation'), ...                                                    % Directory location where the 'scripts' subdirectory resides.
            'alternateFastDataDir',  '',  ...                                                                                          % Alternate FAST (hash) data directory location. Specify '' to use the default location, i.e., $validationRootDir/data/fast
            'alternateFullDataDir',  '', ... % fullfile(filesep,'Users', 'Shared', 'Dropbox', 'theProjectFullValidationData'), ...          % Alternate FULL data directory location. Specify '' to use the default location, i.e., $validationRootDir/data/full
            'clonedWikiLocation',    fullfile(filesep,'Users',  'Shared', 'Matlab', 'Toolboxes', 'theProject_Wiki', 'theProject.wiki'), ... % Local path to the directory where the wiki is cloned. Only relevant for publishing tutorials.
            'clonedGhPagesLocation', fullfile(filesep,'Users',  'Shared', 'Matlab', 'Toolboxes', 'theProject_GhPages', 'theProject'), ...   % Local path to the directory where the gh-pages repository is cloned. Only relevant for publishing tutorials.
            'githubRepoURL',         'http://theProject.github.io/theProject', ...                                                           % Github URL for the project. This is only used for publishing tutorials.
            'generateGroundTruthDataIfNotFound',   false ...                                                                                % Flag indicating whether to generate ground truth if one is not found
        );

    generatePreferenceGroup(p);

    UnitTest.usePreferencesForProject(p.projectName);

end

function generatePreferenceGroup(p)
    % remove any existing preferences for this project
    if ispref(p.projectName)
        rmpref(p.projectName);
    end
    
    % generate and save the project-specific preferences
    setpref(p.projectName, 'projectSpecificPreferences', p);
    fprintf('Generated and saved preferences specific to the ''%s'' project.\n', p.projectName);
end