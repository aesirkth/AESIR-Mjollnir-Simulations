if writing_video
video_index = 1;

if ~isfolder(mypath+"result_videos")
mkdir(mypath+"result_videos")
end


while isfile(mypath+"result_videos\sim"      +string(video_index)+".mp4")
video_index = video_index +1;
end



videoObj1 = VideoWriter(mypath+"result_videos\sim"      +string(video_index)+".mp4","MPEG-4");
open(videoObj1);
end


if writing_gif
gif_index   = 1;
if ~isfolder(mypath+"result_gifs")
mkdir(mypath+"result_gifs")
end

while isfile(mypath+"result_gifs\sim"      +string(gif_index)+".gif")
gif_index = gif_index +1;
end
end