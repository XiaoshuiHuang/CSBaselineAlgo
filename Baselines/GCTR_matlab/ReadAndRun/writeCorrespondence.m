function c=writeCorrespondence(Xc,pathSave)

fid=fopen(pathSave,'wt');
[m,n]=size(Xc);

for i=1:1:m
for j=1:1:n
    if(j==n)
        fprintf(fid,'%g\n',Xc(i,j));
    else
        fprintf(fid,'%g\t',Xc(i,j));
    end
        
end
end

fclose(fid);