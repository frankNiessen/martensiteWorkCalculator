function saveImgs(h,outPath,fileformat,sz)
%function saveImgs(h,outPath,fileformat,sz)

if isa(fileformat,'char')
    tmp{1} = fileformat;
    fileformat = tmp;
    clear tmp
end
if ~isdir(outPath)
    mkdir(outPath);
end
for i = 1:length(h.fig) 
    fName = get(h.fig(i),'name');
    scrPrnt('Step',sprintf('Saving figure ''%s'' in format(s) ''%s''',fName,sprintf('%s ' ,fileformat{:})));
    set(h.fig(i),'renderer','opengl','invertHardcopy','off',...
                     'units','inch','outerposition',[1,1,1+sz(1),1+sz(2)],'color','w');         
    for j = 1:length(fileformat)
        if any(strcmpi(fileformat{j},{'tiff','tif'}))
            print(h.fig(i),[outPath,'\',fName,'.tiff'],'-dtiff','-r600');   
        elseif strcmpi(fileformat{j},'eps')
            print(h.fig(i),[outPath,'\',fName,'.eps'],'-depsc','-painters'); 
        elseif strcmpi(fileformat{j},'fig')
            savefig(h.fig(i),[outPath,'\',fName,'.fig']);
        end
    end
end

if isfield(h,'figVar')
    for i = 1:length(h.figVar) 
        fName = get(h.figVar(i),'name');
        scrPrnt('Step',sprintf('Saving figure ''%s'' in format(s) ''%s''',fName,sprintf('%s ' ,fileformat{:})));
        set(h.figVar(i),'renderer','opengl','invertHardcopy','off',...
                         'units','inch','outerposition',[1,1,1+sz(1),1+sz(2)],'color','w');         
        for j = 1:length(fileformat)
            if any(strcmpi(fileformat{j},{'tiff','tif'}))
                print(h.figVar(i),[outPath,'\',fName,'.tiff'],'-dtiff','-r600');   
            elseif strcmpi(fileformat{j},'eps')
                print(h.figVar(i),[outPath,'\',fName,'.eps'],'-depsc','-painters'); 
            elseif strcmpi(fileformat{j},'fig')
                savefig(h.figVar(i),[outPath,'\',fName,'.fig']);
            end
        end
    end
end
end