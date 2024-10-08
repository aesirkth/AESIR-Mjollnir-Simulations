function render_job = run_rendering_job(render_job, sim)
if ~exist("sim", "var")
load(render_job.sim_name, "sim");
end

if render_job.record_video; render_job.vidobj = VideoWriter(render_job.video_name, "MPEG-4"); end
[ui, render_job] = configure_sim2ui(sim, render_job);
while exist("ui", "var"); try push_sim2ui(sim, render_job, ui); catch; break; end; end
        
if render_job.record_video; close(render_job.vidobj); end

render_job.is_done = true;