package com.umugram.Tfg.domain;

import java.util.Objects;

import jakarta.persistence.*;

@Embeddable
public class Profile {
	
	@Column(nullable = false)
	private String nameProfile;

    private String avatar_url;
    
    @Lob
    private String description;
    
    private String website;

    public Profile(){}
    
    public Profile(String nameProfile)
    {
    	this.nameProfile = nameProfile;
    }
    
    public String getNameProfile() {
    	return nameProfile;
    }
    
	public void setNameProfile(String nameProfile) {
		this.nameProfile = nameProfile;
	}

    public String getAvatar_url() {
        return avatar_url;
    }

    public void setAvatar_url(String avatar_url) {
        this.avatar_url = avatar_url;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getWebsite() {
        return website;
    }

    public void setWebsite(String website) {
        this.website = website;
    }

	@Override
	public int hashCode() {
		return Objects.hash(avatar_url, description, nameProfile, website);
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		Profile other = (Profile) obj;
		return Objects.equals(avatar_url, other.avatar_url) && Objects.equals(description, other.description)
				&& Objects.equals(nameProfile, other.nameProfile) && Objects.equals(website, other.website);
	}
    
    
}
