

cd ann_mwrapper
ann_compile_mex
cd ..

mex mexSource/mexComputeFeature.cpp -output mex/mexComputeFeature -g
mex mexSource/mexTensorMatching.cpp -output mex/mexTensorMatching -g


