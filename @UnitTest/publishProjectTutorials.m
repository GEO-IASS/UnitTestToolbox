% Method to publish a project's tutorials
function publishProjectTutorials(p, scriptsToSkip, scriptCollection)


    % unload params struct
    varNames = fieldnames(p);
    for k = 1:numel(varNames)
        eval(sprintf('%s = p.%s;', varNames{k}, varNames{k}));
    end
    
    % assmble path to tutorialsHTMLdir
    tutorialsHTMLdir = fullfile(ghPagesCloneDir, tutorialsTargetHTMLsubdir);
    
    % cd to wikiCloneDir and do a git pull before any file updating
    cd(wikiCloneDir);
    issueGitCommand('git pull', verbosity);

    
    % set to true when having trouble synchronizing with github  
    removeAllTargetHTMLDirs = false;
    
    % generate tutorialsHTMLdir
    if (exist(tutorialsHTMLdir, 'dir')==7)
        if (removeAllTargetHTMLDirs)
            if (verbosity > 1)
                fprintf('Removing previously existing dir ''%s''\n', tutorialsHTMLdir);
            end
            system(sprintf('rm -r -f %s',tutorialsHTMLdir));
        end
    else    
        mkdir(tutorialsHTMLdir);
    end
    
    % cd to tutorialsHTMLdir and do a git pull before any file updating
    cd(tutorialsHTMLdir);
    issueGitCommand('git pull', verbosity);
    
    
    existingSectionNames = {};
    filesFullList = getContents(tutorialsSourceDir, {});
  
    if strcmp(scriptCollection, 'All')
        filesList = filesFullList;
    else
        filesList = SelectSingleTutorial(filesFullList, scriptsToSkip, tutorialsSourceDir);
    end
    
    
    cd(rootDirectory);
      
    % Open new tutorialsCatalogFile
    tutorialsCatalogFile = fullfile(wikiCloneDir, 'Tutorials.md');
    if (numel(filesList) > 1)
        tutorialsCatalogFileFID = fopen(tutorialsCatalogFile,'w');
    
        % Write the header text.
        fprintf(tutorialsCatalogFileFID, headerText);
        fprintf(tutorialsCatalogFileFID,'***\n_**Last run performed on %s**._\n***', datestr(now));
    else
        tutorialsCatalogFileFID = fopen(tutorialsCatalogFile,'r+');
    end
    
    
    % Start running and publishing
    for k = 1:numel(filesList)
        % close all figures
        close all;
        
        skipThisOne = false;
        for l = 1:numel(scriptsToSkip)
            s = scriptsToSkip{l};
            if (strfind(filesList{k}, s))
                skipThisOne = true;
            end
        end
            
        if (skipThisOne)
            fprintf(2,'[%2d]. Skipping script ''%s''\n', k, filesList{k});
            continue;
        end
        
        % get script name and publish it
        scriptName = filesList{k};
        if (numel(filesList) > 1)
            fprintf('[%2d]. Running and publishing script ''%s''\n', k, scriptName);
        else
            fprintf('Running and publishing script ''%s''\n', scriptName);
        end
        
        runtimeError = false;
        try
            options.catchError = false;
            HTMLfile = publish(scriptName, options);
        catch err
            fprintf(2, '\tScript ''%s'' raised a runtime error (''%s'')\n', scriptName, err.message);
            runtimeError = true;
        end
        
        if (runtimeError)
            continue;
        end
        
        % generate targetHTMLDir
        idx = strfind(HTMLfile, '/html/');
        sourceHTMLdir = HTMLfile(1:idx+length('/html/')-2);
        sectionAndScript = scriptName(length(tutorialsSourceDir)+1:end-2);
        targetHTMLDir = fullfile(tutorialsHTMLdir, sectionAndScript);
        
        if (exist(targetHTMLDir, 'dir')==0)
            mkdir(targetHTMLDir);
        end
        
        % mv sourceHTMLdir contents to targetHTMLDir
        syscommand = sprintf('mv %s/* %s/', sourceHTMLdir, targetHTMLDir);
        if (verbosity > 1)
            fprintf('Executing %s\n',  syscommand);
        end
        system(syscommand);
        
        % rm sourceHTMLdir
        syscommand = sprintf('rm -r -f %s', sourceHTMLdir);
        system(syscommand);
        
        if (verbosity > 1)
            % feedback to user
            fprintf('''%s'' -> ''%s'' \n',  scriptName, targetHTMLDir);
        end
        
        % update tutorialsCatalogFile
        idx = strfind(sectionAndScript, '/');
        sectionName     = sectionAndScript(2:idx(2)-1);
        smallScriptName = sectionAndScript(idx(2)+1:end);
        tutorialURL     = sprintf('http://isetbio.github.io/isetbio/tutorialdocs/%s/%s/%s.html', sectionName, smallScriptName, smallScriptName);
        
        if (~ismember(sectionName, existingSectionNames))
            existingSectionNames{numel(existingSectionNames)+1} = sectionName;
            if (numel(filesList) > 1)
                % write sectionName
                fprintf(tutorialsCatalogFileFID,'\n####  %s \n', sectionName);
            else
                % search the file for the pattern
                patternToLookUp = sprintf('####  %s', sectionName);
                fseek(tutorialsCatalogFileFID, 0, 'bof');
                position = [];
                while ~feof(tutorialsCatalogFileFID) 
                    tline = fgetl(tutorialsCatalogFileFID); 
                    if strfind(tline, patternToLookUp) > 0 
                        fprintf('Found pattern ''%s''', patternToLookUp);
                        position = ftell(tutorialsCatalogFileFID);
                    end
                end
                if (~isempty(position))
                    % Go right before the sectionName
                    fseek(tutorialsCatalogFileFID, position, 'bof');
                else
                    % Go to the end of the file
                    fseek(tutorialsCatalogFileFID, 0, 'eof');
                    % and write new section name
                    fprintf(tutorialsCatalogFileFID,'\n####  %s \n', sectionName);
                end
            end
        end
        
        if (numel(filesList) > 1)
            % Add entry to tutorialsCatalogFile
            fprintf(tutorialsCatalogFileFID, '* [ %s ](%s) \n',  smallScriptName, tutorialURL);  
        else
            % search the file for the pattern
            patternToLookUp = sprintf('* [ %s ]',  smallScriptName);  
            fseek(tutorialsCatalogFileFID, 0, 'bof');
            position = [];
            fileContents = fscanf(tutorialsCatalogFileFID, '%c', Inf);
            position = strfind(fileContents, patternToLookUp)-1;
            if (~isempty(position))
                userName =  char(java.lang.System.getProperty('user.name'));
                computerAddress  = char(java.net.InetAddress.getLocalHost.getHostName);
                insertedFileContents = sprintf('\n***Note: Tutorial ''%s'' was updated separately on %s by %s (host name: %s).***\n', smallScriptName, datestr(now), userName, computerAddress);
                newFileContents(1:position) = fileContents(1:position);
                remainingFileContents = fileContents(position+1:end);
                newFileContents(position+1:position+numel(insertedFileContents)) = insertedFileContents;
                p = numel(newFileContents);
                newFileContents(p+1:p+numel(remainingFileContents)) = remainingFileContents;
                fclose(tutorialsCatalogFileFID);
                    
                system(['rm -rf ' tutorialsCatalogFile]);
    
                % Open new tutorialResultsCatalogFile
                tutorialsCatalogFileFID = fopen(tutorialsCatalogFile,'w');
                fprintf(tutorialsCatalogFileFID, '%c', newFileContents);
            else
                % Go to the end of the file
                fseek(validationResultsCatalogFID, 0, 'eof');
                % Add entry to tutorialsCatalogFile
                fprintf(tutorialsCatalogFileFID, '* [ %s ](%s) \n',  smallScriptName, tutorialURL);  
            end
        end
    end  % k
    
    % Close the tutorialsCatalogFileFID
    fclose(tutorialsCatalogFileFID);
    
    cd(tutorialsHTMLdir);
    
    % -------- Push the HTML tutorial datafiles ---------
    cd(tutorialsHTMLdir);
    
    issueGitCommand('git config --global push.default matching', verbosity);

    % Stage everything
    issueGitCommand('git add -A', verbosity);
    
    % Commit everything
    issueGitCommand('git commit -a -m "Tutorials docs update";', verbosity);
    % Push to remote
    issueGitCommand('git push  origin gh-pages',verbosity);
    
    
    
    
    % ---------- Push the tutorials catalog -------------
    cd(wikiCloneDir);
    
    issueGitCommand('git config --global push.default matching', verbosity);
    
    % Stage everything
    issueGitCommand('git add -A', verbosity);
    

    % Commit everything
    issueGitCommand('git commit  -a -m "Tutorials catalog update";', verbosity);
    % Push to remote
    issueGitCommand('git push', verbosity);
    
    % All done. Return to root directory
    cd(rootDirectory);
end

function tutorialToPublish = SelectSingleTutorial(filesFullList, scriptsToSkip, tutorialsSourceDir)
    
    fprintf('\n\n---------------------------------------------------------------------------\n');
    fprintf('Available tutorials                                     Tutorial no. \n');
    fprintf('---------------------------------------------------------------------------\n');
                
    existingSectionNames = {};
    filesList = {};
    for k = 1:numel(filesFullList)
        scriptName = filesFullList{k};
        skipThisOne = false;
        for l = 1:numel(scriptsToSkip)
            s = scriptsToSkip{l};
            if (strfind(scriptName, s))
                skipThisOne = true;
            end
        end
        
        if (skipThisOne)
            continue;
        end
        
        filesList{numel(filesList)+1} = scriptName;
        
        sectionAndScript = scriptName(length(tutorialsSourceDir)+1:end-2);
        idx = strfind(sectionAndScript, '/');
        sectionName     = sectionAndScript(2:idx(2)-1);
        smallScriptName = sectionAndScript(idx(2)+1:end);
        
        if (~ismember(sectionName, existingSectionNames))
           existingSectionNames{numel(existingSectionNames)+1} = sectionName;
           fprintf('<strong>%s</strong>\n', sectionName);
        end
        dots = '';
        for kk = 1:50-numel(smallScriptName)
           dots(kk) = '.';
        end
        fprintf('\t%s %s %3d\n',  smallScriptName, dots, numel(filesList));
    end % for k
    
    selectedScriptIndex = input(sprintf('\nEnter tutorial no. to publish [%d-%d]: ', 1, numel(filesList)));
    if (isempty(selectedScriptIndex)) || (~isnumeric(selectedScriptIndex))
        error('input must be a numeral');
    elseif (selectedScriptIndex <= 0) || (selectedScriptIndex > numel(filesList))
        error('input must be in range [%d .. %d]', 1, numel(filesList));
    else
        tutorialToPublish = {filesList{selectedScriptIndex}};
    end
    
end


function updatedFileList = getContents(directory, fileList)
    oldFileList = fileList;
    cd(directory);
    
    % look for m-files
    contents = dir('*.m');
    for k = 1:numel(contents)
        oldFileList{numel(oldFileList)+1} = fullfile(directory,contents(k).name);
    end
    
    % look for subdirs
    contents = dir;
    for k = 1:numel(contents)
        if (contents(k).isdir) && (~strcmp(contents(k).name, '.')) && (~strcmp(contents(k).name, '..')) && (~strcmp(contents(k).name, 'html'))
           oldFileList = getContents(fullfile(directory,contents(k).name), oldFileList); 
        end
    end
    
    updatedFileList = oldFileList;
end


% Method to issue a git command with output capture
function issueGitCommand(commandString, verbosity)

    [status,cmdout] = system(commandString,'-echo');
    
    if (verbosity > 1)
        disp(cmdout)
    end
end

