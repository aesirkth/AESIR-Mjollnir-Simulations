function render_job = run_rendering_job(render_job, sim)
if ~exist("sim", "var")
load(render_job.sim_name, "sim");
end

%% Setup
ui = initiate_ui(); initiate_nodes(ui.Tree, sim.rocket.name, sim.rocket_historian);


if render_job.record_video
if isfile(render_job.video_name); delete(render_job.video_name); end
render_job.vidobj = VideoWriter(render_job.video_name, "MPEG-4"); render_job.vidobj.FrameRate = render_job.framerate; 
open(render_job.vidobj); 
end

if render_job.record_gif
if isfile(render_job.gif_name); delete(render_job.gif_name); end
img = getframe(ui.UIFigure); img = frame2im(img); [img,cmap] = rgb2ind(img, 256);
imwrite(img, cmap, render_job.gif_name, "gif", LoopCount=Inf, Delaytime = 1/render_job.framerate); 
end
    
%% Main loop
render_job.rendering = true;
while render_job.rendering
   draw_sim(ui,sim); 

if render_job.record_video
    writeVideo(render_job.vidobj, getframe(ui.UIFigure)); 
end
if render_job.record_gif
    img = getframe(ui.UIFigure); img = frame2im(img); [img,cmap] = rgb2ind(img, 256);    
    imwrite(img, cmap, render_job.gif_name, "gif", WriteMode="append", DelayTime=1/render_job.framerate); 
end
    
    if render_job.close_on_finish &&  ui.TSlider.Value == ui.TSlider.Limits(2); render_job.rendering = false;  end
end

% Close
close(ui.UIFigure); clear ui;
if render_job.record_video; close(render_job.vidobj); end

render_job.is_done = true;