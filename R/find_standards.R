'find_standards' <- function(subdirs = c('RFM processing inputs/Orthomosaics', 'Share/Photogrammetry DEMs', 'Share/Canopy height models'), 
                             basedir = 'c:/Work/etc/saltmarsh/data', resultbase = 'c:/Work/etc/saltmarsh/data') {
   
   # Find raster standard for each site that doesn't already have one. It will be the oldest Mica file for each site.
   # Arguments:
   #     subdirs        subdirectories to search, ending with slash. Default = orthos, DEMs, and canopy height models (okay to include empty or
   #                    nonexistent directories)
   #     basedir        full path to subdirs
   #     resultbase     base name of result base directory
   # 
   # Source: 
   #     geoTIFFs for each site
   #     pars/sites.txt    table of site abbreviation, site name, footprint shapefile, raster standard
   #
   # Results: 
   #     resultbase/sites.txt    new version of sites file. *** Copy this to pars/sites.txt after running ***
   # 
   # Selected standards must be in EPSG:4326. A warning will be returned for files in other projections; you'll have to reproject
   # the source file or pick a standard manually for these sites.
   # 
   # B. Compton, 4 Feb 2025
   
   
   
   subdirs = c('Orthomosaics/', 'Photogrammetry DEMs/', 'Canopy height models/')      ##### for testing on my laptop
   
   
   library(terra)
   
   
   sites <- read.table('pars/sites.txt', sep = '\t', header = TRUE)                 # read sites file
   
   for(i in 1:dim(sites)[1]) {                                                      # for each site,
      dir <- file.path(basedir, sites$site_name[i], '/')
      x <- NULL
      for(j in subdirs)                                                             #    for each subdir,
         x <- c(x, paste0(j, list.files(file.path(dir, j))))                        #       get filenames ending in .tif
      x <- x[grep('.tif$', x)]
      if(str_length(standard <- sites$standard[i]) == 0) {                          #    if standard supplied for this site, use it; else take earliest Mica Orthomosaic
         d <- str_split(y <- x[grep('mica_ortho', tolower(x))], '_')         
         d <- dmy(unlist(lapply(d, '[[', 1)))
         std <- y[order(d)[1]]
         if(!is.na(std)) {
            sites$standard[i] <- std
            g <- rast(file.path(dir, std))
            if(paste(crs(g, describe = TRUE)[c('authority', 'code')], collapse = ':') != 'EPSG:4326') {
               warning(paste0(std, ' has a non-standard projection. Standards must be EPSG:4326. Reproject it or pick a different standard.'))
               sites$standard[i] <- paste0(std, '   *** BAD PROJECTION ***')
            }
         }
      }
   }
   
   
   write.table(sites, f <- file.path(resultbase, 'sites.txt'), sep = '\t', row.names = FALSE, quote = FALSE)
   cat('New sites file written to ', f, '\n', sep = '')
}
