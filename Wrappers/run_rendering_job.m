function render_job = run_rendering_job(render_job, sim)
if ~exist("sim", "var")
load(render_job.sim_name, "sim");
end


[ui, render_job] = configure_sim2ui(sim, render_job);
render_job.rendering = true;

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
    

while render_job.rendering; render_job = push_sim2ui(sim, render_job, ui); end
        
if render_job.record_video; close(render_job.vidobj); end

render_job.is_done = true;