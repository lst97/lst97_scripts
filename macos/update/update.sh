echo "##### UPDATEING MACOS #####";
softwareupdate -l
echo "##### UPDATEING BREW #####";
brew update;
brew upgrade;
echo "##### UPDATEING NodeJS all packages#####";
npm update -g;
echo "##### UPDATEING pip packages [GLOBAL] #####";
source ~/miniconda3/etc/profile.d/conda.sh && conda deactivate && conda deactivate && pip-review --auto
echo "##### UPDATEING conda pip packages [BASE] #####";
source ~/miniconda3/etc/profile.d/conda.sh && conda activate base && conda update conda -y && conda update python -y && pip-review --auto;
echo "##### UPDATEING conda pip packages [CONDA] #####";
source ~/miniconda3/etc/profile.d/conda.sh && conda activate conda && conda update python -y && pip-review --auto;
echo "DONE!"
read -p "Press enter to quit"