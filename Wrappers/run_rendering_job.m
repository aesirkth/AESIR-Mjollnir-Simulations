function run_rendering_job(render_job)

load(render_job.sim_name, "sim");
    
if render_job.record_video; render_job.vidobj = VideoWriter(render_job.video_name, "MPEG-4"); end
[ui, render_job] = configure_sim2ui(sim, render_job);
while exist("ui", "var"); try push_sim2ui(sim, render_job, ui); catch; break; end; end
        
if render_job.record_video; close(render_job.vidobj); end