function render_job = render_simulation(sim, render_job)
%% render_simulation(sim, render_job)
%
% Parameter                      Class                   Default       Description             
%______________________________:_______________________:___________:________________________________________________________
% render_job                   : struct                : N/A       :   specify how the job should be run
% render_job.play_on_startup   : string                : true      :   whether or not rendering should be done immediately upon ui spawning
% render_job.close_on_finish   : boolean               : false     :   whether or not ui should be closed when timebar hits end
% render_job.record_video      : boolean               : false     :   whether or not the render should be saved as a video
% render_job.record_gif        : boolean               : false     :   whether or not the render should be saved as a gif
% render_job.is_done           : boolean               : false     :   false if job has yet to be completed
% render_job.overwrite         : boolean               : false     :   whether or not the video rendered should replace the old one in case of conflict with previous file   
% render_job.framerate         : int                   : 30        :   framerate
% render_job.video_name        : string                : sim.name  :   name of video-file  



if ~exist("render_job", "var");             render_job                 = struct(); end
if ~isfield(render_job, "play_on_startup"); render_job.play_on_startup = true;     end
if ~isfield(render_job, "close_on_finish"); render_job.close_on_finish = false;    end
if ~isfield(render_job, "record_video");    render_job.record_video    = false;    end
if ~isfield(render_job, "record_gif");      render_job.record_gif      = false;    end
if ~isfield(render_job, "overwrite");       render_job.overwrite       = false;    end
if ~isfield(render_job, "is_done");         render_job.is_done         = false;    end
if ~isfield(render_job, "framerate");       render_job.framerate       = 30;       end
if ~isfield(render_job, "video_name");      render_job.video_name      = strrep(strrep(sim.job.name, "/sims/", "/videos/"), ".mat", ".mp4"); end

if ~exist("sim", "var")
load(render_job.sim_name, "sim");
end

%% Setup
ui = initiate_ui(); initiate_nodes(ui.Tree, sim.initial_rocket.name, sim.rocket_historian);


if render_job.record_video
if isfile(render_job.video_name); delete(render_job.video_name); end
render_job.vidobj = VideoWriter(render_job.video_name, "MPEG-4"); render_job.vidobj.FrameRate = render_job.framerate; %render_job.vidobj.FrameCount = sim.job.t_max*render_job.framerate;
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
   draw_sim(ui,sim, 1/render_job.framerate); 

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