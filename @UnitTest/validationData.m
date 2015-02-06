% Method to add new data to the validation data struct
function data = validationData(varargin)
    
    persistent validationData
    
    data = [];
    
    if ischar(varargin{1}) && ischar(varargin{2}) && (strcmp(varargin{1}, 'command')) && (strcmp(varargin{2}, 'init'))
        validationData = struct();
        return;
    end
    
    if ischar(varargin{1}) && ischar(varargin{2}) && (strcmp(varargin{1}, 'command')) && (strcmp(varargin{2}, 'return'))
        data = validationData;
        return;
    end
    
    if (getpref('UnitTest', 'inStandAloneMode'))
        % this is the case when we run in stand-alone mode, so we do not
        % want to do anything else here
        return;
    end
    
    % Parse inputs
    for k = 1:2:numel(varargin)
        fieldName = varargin{k};
        fieldValue = varargin{k+1};
        % make sure field does not already exist
        if ismember(fieldName, fieldnames(validationData))
            fprintf(2,'\tField ''%s'' already exists in the validationData struct. Its value will be overriden.\n', fieldName);
        end
        
        % save the full data
        validationData.(fieldName) = fieldValue;
       
        % save truncated data in hashData.(fieldName)
        if (isnumeric(fieldValue))
            validationData.hashData.(fieldName) = UnitTest.roundToNdigits(fieldValue, UnitTest.decimalDigitNumRoundingForHashComputation);
        elseif (isstruct(fieldValue))
            validationData.hashData.(fieldName) = roundStruct(fieldValue);
        elseif (iscell(fieldValue))
            validationData.hashData.(fieldName) = roundCellArray(fieldValue);
        elseif (ischar(fieldValue))
            % only add string field if we are comparing them
            % get current project name
            theProjectName = getpref('UnitTest', 'projectName');
            compareStringFields = getpref(theProjectName, 'compareStringFields');
            if (compareStringFields)
                validationData.hashData.(fieldName) = fieldValue;
                %fprintf('ADDING CHAR FIELD %s TO HASH DATA', fieldName); 
            else
                validationData.hashData.(fieldName) = '';
                %fprintf('NOT ADDING CHAR FIELD %s TO HASH DATA', fieldName); 
            end
        elseif (islogical(fieldValue))
            validationData.hashData.(fieldName) = fieldValue;
        else
            error('Do not know how to round param ''%s'', which is of  class type:''%s''. ', fieldName, class(fieldValue));
            %validationData.hashData.(fieldName) = fieldValue;
        end
 
    end
         
end

% Method to recursive round a struct
function s = roundStruct(oldStruct)

    s = oldStruct;
    
    if (isempty(s))
        return;
    end
    
    structFieldNames = fieldnames(s);
    for k = 1:numel(structFieldNames)
        
        % get field
        fieldValue = s.(structFieldNames{k});
        
        if isstruct(fieldValue)
            s.(structFieldNames{k}) = roundStruct(fieldValue);
        elseif ischar(fieldValue)
            % Get current project name
            theProjectName = getpref('UnitTest', 'projectName');
            compareStringFields = getpref(theProjectName, 'compareStringFields');
            if (compareStringFields)
                %fprintf('ADDING CHAR FIELD %s TO HASH DATA', structFieldNames{k}); 
            else
                s.(structFieldNames{k}) = '';
                %fprintf('NOT ADDING CHAR FIELD %s TO HASH DATA', structFieldNames{k}); 
            end
        elseif isnumeric(fieldValue)
            s.(structFieldNames{k}) = UnitTest.roundToNdigits(fieldValue, UnitTest.decimalDigitNumRoundingForHashComputation);
        elseif iscell(fieldValue)
            s.(structFieldNames{k}) = roundCellArray(fieldValue);
        elseif (islogical(fieldValue))
            s.(structFieldNames{k}) = fieldValue;
        else
            error('Do not know how to round param ''%s'', which is of  class type:''%s''. ', structFieldNames{k}, class(fieldValue));
        end
    end
    
end


% Method to recursive round a cellArray
function cellArray = roundCellArray(oldCellArray)
    cellArray = oldCellArray;
    
    for k = 1:numel(cellArray)
        fieldValue = cellArray{k};
        
        % Char values
        if ischar(fieldValue)
            % Get current project name
            theProjectName = getpref('UnitTest', 'projectName');
            compareStringFields = getpref(theProjectName, 'compareStringFields');
            if (compareStringFields)
            else
                cellArray{k} = '';
                %fprintf('NOT ADDING CHAR FIELD TO HASH DATA'); 
            end
             
        % Numeric values
        elseif (isnumeric(fieldValue))
            cellArray{k} = UnitTest.roundToNdigits(fieldValue, UnitTest.decimalDigitNumRoundingForHashComputation);
        
        % Cells
        elseif (iscell(fieldValue))
            cellArray{k} = roundCellArray(fieldValue);
            
        % Logical
        elseif (islogical(fieldValue))
            cellArray{k} = fieldValue;
            
        % Struct
         elseif (isstruct(fieldValue))
             cellArray{k} = roundStruct(fieldValue);
            
        else
            error('Do not know how to round cell entry which is of class type:''%s''. ',  class(fieldValue));
        end
    end
end

    