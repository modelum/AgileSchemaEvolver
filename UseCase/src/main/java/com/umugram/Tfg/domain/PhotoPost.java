package com.umugram.Tfg.domain;

import jakarta.persistence.*;


@Entity
public class PhotoPost extends Post {

    private String photoUrl;

    public PhotoPost(String caption, String photoUrl) {
        super(caption);
        this.photoUrl = photoUrl;
    }

    public PhotoPost() {}

    // Getters y Setters
    public String getPhotoUrl() {
        return photoUrl;
    }

    public void setPhotoUrl(String photoUrl) {
        this.photoUrl = photoUrl;
    }
}