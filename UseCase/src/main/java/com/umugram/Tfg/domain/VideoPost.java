package com.umugram.Tfg.domain;

import jakarta.persistence.Entity;

@Entity
public class VideoPost extends Post {

    private String videoUrl;
    private double duration;
    private double lastMinute;

    public VideoPost(String caption, String videoUrl, double duration) {
        super(caption);
        this.videoUrl = videoUrl;
        this.duration = duration;
        lastMinute = 0;
    }

    public VideoPost(){}

    // Getters y Setters

    public String getVideoUrl() {
        return videoUrl;
    }

    public void setVideoUrl(String videoUrl) {
        this.videoUrl = videoUrl;
    }

    public double getDuration() {
        return duration;
    }

    public void setDuration(double duration) {
        this.duration = duration;
    }

    public double getLastMinute() {
        return lastMinute;
    }

    public void setLastMinute(double lastMinute) {
        this.lastMinute = lastMinute;
    }

}
