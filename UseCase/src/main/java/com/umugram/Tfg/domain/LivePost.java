package com.umugram.Tfg.domain;

import jakarta.persistence.*;

@Entity
@NamedQuery(name = "LivePost.findAllActiveStreams", query = "SELECT l FROM LivePost l JOIN FETCH  l.user u WHERE l.duration > 0 and u = :user")
public class LivePost extends Post{
    private String streamUrl;
    private double duration;

    public LivePost(String caption, String streamUrl, double duration) {
        super(caption);
        this.streamUrl = streamUrl;
        this.duration = duration;
    }

    public LivePost() {}

    // Getters y Setters
    public String getStreamUrl() {
        return streamUrl;
    }

    public void setStreamUrl(String streamUrl) {
        this.streamUrl = streamUrl;
    }

    public double getDuration() {
        return duration;
    }

    public void setDuration(double duration) {
        this.duration = duration;
    }

    @Override
    public String toString() {
        return "LivePost{" +
                "streamUrl='" + streamUrl + '\'' +
                ", duration=" + duration +
                ", caption='" + getCaption() + '\'' +
                '}';
    }
}
