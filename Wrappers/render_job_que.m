function render_job_que(render_jobs)

for job_index = 1:numel(render_jobs)
if  ~render_jobs{job_index}.is_done

        load(render_jobs{job_index}.sim_name, "sim");
    
        if render_jobs{job_index}.record_video; render_jobs{job_index}.vidobj = VideoWriter(render_jobs{job_index}.video_name, "MPEG-4"); end
        [ui, render_jobs{job_index}] = configure_sim2ui(sim, render_jobs{job_index});
    
                        name = render_jobs{job_index}.sim_name
        while exist("ui", "var"); try push_sim2ui(sim, render_jobs{job_index}, ui); catch; break; end; end
        
        if render_jobs{job_index}.record_video; close(render_jobs{job_index}.vidobj); end
        render_jobs{job_index}.is_done = true;
        save("render_jobs.mat", "render_jobs")
    
end
end