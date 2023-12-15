%************************************************************************************************************************
%************************************************************************************************************************

%Be sure about the path contain New_Actin_Analysis.m

%cd '\\sv5\public\Sekine\NEW_Results\m_e1-2'     %Location of the folder where you have the binary images

clear

cd '/Users/ssekine/Documents/MATLAB/zipROD_e6_5_2/'   %XXXXXXXXXXXXXX !!!

Numb_of_Images = 100;                  %% input the numbe of images you have

%Result_address = '\\sv5\public\Sekine\NEW_Results\'; %location of the folder must called "NEW_Results" where to save excel file of the result

Result_address = '/Users/ssekine/Documents/MATLAB/zipROD/';  %XXXXXXXXXXXXXX !!!

%************************************************************************************************************************
%************************************************************************************************************************
%Excel_filename = ['\\sv5\Public\Sekine\coloc_watershed\NEW_Results\NEW_Results.xlsx']; %where to save excel file of result

Excel_filename = [Result_address,'zipROD_e6_5_2.xlsx'];  %XXXXXXXXXXXXXX !!!


[fileName,pathName] = uigetfile('*.tif' )
dname       = fullfile(pathName,fileName)
filelist = dir([fileparts(dname) filesep '*.tif']);
fileNames = {filelist.name}';
num_frames = (numel(filelist));


for Count = 1:Numb_of_Images-1
    
    Image_1 = imread(fullfile(pathName, fileNames{Count}));
    
    Image_2 = imread(fullfile(pathName, fileNames{Count+1}));
    
    %%
    BW_Image_1 = im2bw(Image_1);
    BW_Image_2 = im2bw(Image_2);
    
    
    %% Remove very small objects from image_1 and image_2 (6 to 53 pixels)
    Large_Obj_Image_1 = bwareafilt (BW_Image_1, [6 53]);
    Large_Obj_Image_1 = imclearborder(Large_Obj_Image_1); %remove objects at the boundary
    
    
    Large_Obj_Image_2 = bwareafilt (BW_Image_2,  [1 Inf]); %no limitation
    Large_Obj_Image_2 = imclearborder(Large_Obj_Image_2);%remove objects at the boundary
    
    
    %% Find  intersections
    
    Intersect_Type_1_or_2 =  immultiply(Large_Obj_Image_1,Large_Obj_Image_2);
    
    
    %% Find the full size of those intersected type 1 or 2
    
    [Labels NumberOfObjects] = bwlabel(Intersect_Type_1_or_2, 8);
    
    
    %%
    Cummulative_image = im2bw(zeros(size(Large_Obj_Image_2)));
    %%
    for CellCount = 1:NumberOfObjects
        Cell_Obj = (Labels == CellCount);
        s  = regionprops(Cell_Obj, 'centroid');
        Cell_x_cordinate = s.Centroid(1);
        Cell_y_cordinate = s.Centroid(2);
        
        Full_Obj = bwselect(Large_Obj_Image_2, Cell_x_cordinate, Cell_y_cordinate);
        
        New_Comulative = imadd(Full_Obj, Cummulative_image);
        New_Comulative = im2bw(New_Comulative);
        Cummulative_image = New_Comulative;
    end
    
    
    
    %% make ref_Imge_Centroid_List
    
    ref_Img = Large_Obj_Image_1;
    Cumm_Img = Cummulative_image;
    
    [ref_Labels    ref_NumberOfObjects] = bwlabel(ref_Img, 8);
    
    [Cumm_Labels   Cumm_NumberOfObjects] = bwlabel(Cumm_Img, 8);
    
    
    ManyDistance_List = []
    
    try
        for ref_CellCount = 1:ref_NumberOfObjects
            ref_Cell_Obj = (ref_Labels == ref_CellCount);
            %check if this ref_Cell_Obj has intersection with Cumm_Img
            ref_Cell_Obj_Intersect =  immultiply(ref_Cell_Obj,Cumm_Img);
            
            %Area of the object
            
            Prop_ref_Cell_Obj = regionprops(ref_Cell_Obj, 'Area');
            Area_ref_Cell_Obj = Prop_ref_Cell_Obj.Area;
            
            [Labeled_intersect     ref_Cell_Obj_Intersect_NumberOfObjects ]= bwlabel(ref_Cell_Obj_Intersect,8); %must use 8-connectivity
            
            if ref_Cell_Obj_Intersect_NumberOfObjects>=2  % if more than 2 overlapped objects then take the biggest one (before was nearest one)
                
                
                Intersect_Commulative = im2bw(zeros(size(Large_Obj_Image_2)));
                
                for Many_CellCount = 1:ref_Cell_Obj_Intersect_NumberOfObjects
                    Many_Cell_Obj = (Labeled_intersect == Many_CellCount);
                    
                    
                    Many_Cell_Obj = imfill(Many_Cell_Obj, 'holes');
                    Many_Cell_Obj = bwmorph(Many_Cell_Obj,'shrink', Inf);
                    
                    Many_s  = regionprops(Many_Cell_Obj, 'centroid');
                    Many_Cell_x_cordinate = Many_s.Centroid(1);
                    Many_Cell_y_cordinate = Many_s.Centroid(2);
                    
                    %get back the full object
                    
                    MMany_Cell_Obj = bwselect(Cumm_Img, Many_Cell_x_cordinate, Many_Cell_y_cordinate);
                    
                    % put the image
                    Commu_Biger_Intersect = imadd(Intersect_Commulative,MMany_Cell_Obj);
                    Commu_Biger_Intersect = im2bw(Commu_Biger_Intersect);
                    Intersect_Commulative = Commu_Biger_Intersect;
                    
                end
                
                %Get the largest overlapped object in (Intersect_Commulative)
                
                BW = Intersect_Commulative;
                Labeled_BW = bwlabel(BW,8); %must use 8-connectivity
                Area = regionprops(Labeled_BW,'Area');
                maxArea = max([Area.Area]);
                
                for i=1:size(Area,1)
                    if maxArea==Area(i).Area
                        max_num = i;
                        break
                    end
                end
                
                Largest_Obj = im2bw((Labeled_BW==max_num));
                
                Full_Obj = Largest_Obj;
                
                Area_Full_Obj = regionprops(Full_Obj, 'Area');
                Area_Full_Obj = Area_Full_Obj.Area;
                
                
                ref_sX  = regionprops(Full_Obj, 'centroid');
                Full_Obj_Cord_x_cordinate = ref_sX.Centroid(1);
                Full_Obj_Cord_y_cordinate = ref_sX.Centroid(2);
                
                
                ref_s  = regionprops(ref_Cell_Obj, 'centroid');
                ref_Cell_x_cordinate = ref_s.Centroid(1);
                ref_Cell_y_cordinate = ref_s.Centroid(2);
                
                
                
                ref_Coordinate_List(ref_CellCount,1) = ref_Cell_x_cordinate;
                ref_Coordinate_List(ref_CellCount,2) = ref_Cell_y_cordinate;
                
                ref_Coordinate_List(ref_CellCount,3) = Area_ref_Cell_Obj;
                
                ref_Coordinate_List(ref_CellCount,4) = Full_Obj_Cord_x_cordinate;
                ref_Coordinate_List(ref_CellCount,5) = Full_Obj_Cord_y_cordinate;
                
                ref_Coordinate_List(ref_CellCount,6) = Area_Full_Obj;
                
                
                
            elseif ref_Cell_Obj_Intersect_NumberOfObjects ==1
                
                
                ref_s  = regionprops(ref_Cell_Obj, 'centroid');
                ref_Cell_x_cordinate = ref_s.Centroid(1);
                ref_Cell_y_cordinate = ref_s.Centroid(2);
                
                
                ref_Cell_Obj_Intersect = imfill(ref_Cell_Obj_Intersect, 'holes');
                ref_Cell_Obj_Intersect = bwmorph(ref_Cell_Obj_Intersect,'shrink', Inf);
                
                ref_Cell_Obj_Intersect_Full = regionprops(ref_Cell_Obj_Intersect, 'centroid');
                ref_Cell_Obj_Intersect_Full_x_cordinate = ref_Cell_Obj_Intersect_Full.Centroid(1);
                ref_Cell_Obj_Intersect_Full_y_cordinate = ref_Cell_Obj_Intersect_Full.Centroid(2);
                
                Full_Obj = bwselect(Cumm_Img, ref_Cell_Obj_Intersect_Full_x_cordinate, ref_Cell_Obj_Intersect_Full_y_cordinate);
                
                Full_Obj_Cord = regionprops(Full_Obj, 'centroid');
                Full_Obj_Cord_x_cordinate = Full_Obj_Cord.Centroid(1);
                Full_Obj_Cord_y_cordinate = Full_Obj_Cord.Centroid(2);
                
                
                Area_Full_Obj = regionprops(Full_Obj, 'Area');
                Area_Full_Obj = Area_Full_Obj.Area;
                
                
                ref_Coordinate_List(ref_CellCount,1) = ref_Cell_x_cordinate;
                ref_Coordinate_List(ref_CellCount,2) = ref_Cell_y_cordinate;
                
                ref_Coordinate_List(ref_CellCount,3) = Area_ref_Cell_Obj;
                
                ref_Coordinate_List(ref_CellCount,4) = Full_Obj_Cord_x_cordinate;
                ref_Coordinate_List(ref_CellCount,5) = Full_Obj_Cord_y_cordinate;
                
                ref_Coordinate_List(ref_CellCount,6) = Area_Full_Obj;
                
                
                
            elseif ref_Cell_Obj_Intersect_NumberOfObjects ==0 % no intersection
                ref_s  = regionprops(ref_Cell_Obj, 'centroid');
                ref_Cell_x_cordinate = ref_s.Centroid(1);
                ref_Cell_y_cordinate = ref_s.Centroid(2);
                
                
                Full_Obj_Cord_x_cordinate = 0;  % put zero
                Full_Obj_Cord_y_cordinate = 0;  % put zero
                
                
                %save the coordinates and area
                ref_Coordinate_List(ref_CellCount,1) = ref_Cell_x_cordinate;
                ref_Coordinate_List(ref_CellCount,2) = ref_Cell_y_cordinate;
                
                ref_Coordinate_List(ref_CellCount,3) = Area_ref_Cell_Obj;
                
                ref_Coordinate_List(ref_CellCount,4) = Full_Obj_Cord_x_cordinate;
                ref_Coordinate_List(ref_CellCount,5) = Full_Obj_Cord_y_cordinate;
                
                ref_Coordinate_List(ref_CellCount,6) = 0;
                
                %%
                %ref_Coordinate_List{ref_CellCount,2} = [Full_Obj_Cord_x_cordinate, Full_Obj_Cord_y_cordinate];
                
                
            end
            
            
        end
        
    catch
    end
    ALL_ref_Coordinate_List{Count,1} = ref_Coordinate_List;
    
    clear ref_Coordinate_List %very important
    
    ref_Coordinate_List =[]
end

ALL_Result = cell2mat(ALL_ref_Coordinate_List);


%Save results
%**************************
% Excel_filename = ['\\sv5\Public\Sekine\coloc_watershed\NEW_Results\NEW_Results.xlsx']; % location to save the excel file
sheet = 1;
xlswrite(Excel_filename,ALL_Result)

%**************************

