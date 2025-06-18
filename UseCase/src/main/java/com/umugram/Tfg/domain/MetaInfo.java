package com.umugram.Tfg.domain;

import jakarta.persistence.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.util.*;

@MappedSuperclass
public abstract class MetaInfo {

    @CreationTimestamp
    @Temporal(TemporalType.TIMESTAMP)
    private Date create_at;

    @UpdateTimestamp
    @Temporal(TemporalType.TIMESTAMP)
    private Date update_at;

    protected Date getCreate_at() {
        return create_at;
    }

    protected void setCreate_at(Date create_at) {
        this.create_at = create_at;
    }

    protected Date getUpdate_at() {
        return update_at;
    }

    protected void setUpdate_at(Date update_at) {
        this.update_at = update_at;
    }


}

