# A script to be sourced at the beginning of each working script to load working paths

# Working paths
sys_path <- ifelse(Sys.info()["sysname"]=="Windows", "G:/My Drive/",ifelse(Sys.info()["sysname"]=="Linux", "/home/jason/Documents/Gdrive_sync/emlab_shared/", "~/Google Drive/My Drive/"))
# Path to this project's folder
project_path <- paste0(sys_path,"emLab/Projects/boi-dive-project")
#Path to project's data folder
project_data_path <- file.path(project_path,"data")
# Path to project's output table folder
project_table_path <- file.path(project_path, "tables")
# Path to project's output figure folder
project_figure_path <- file.path(project_path, "figures")

# Path to emLab data drive 
emlab_data_dir <- file.path(ifelse(Sys.info()["sysname"]=="Windows", "G:/My Drive/",ifelse(Sys.info()["sysname"]=="Linux", "/home/jason/Documents/Gdrive_sync/emlab_shared/", "~/Google Drive/Shared drives/")),
                            "emlab", "data")