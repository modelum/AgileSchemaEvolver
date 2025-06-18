package com.umugram.Tfg.domain;

import jakarta.persistence.*;

import java.io.Serial;
import java.io.Serializable;

import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

@Entity
public class Comment extends MetaInfo implements Serializable{

    @Serial
    private static final long serialVersionUID = 1L;

	@Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false, length = 1000)
    @Lob
    private String text;

    @ManyToOne
    private Post post;

    @OnDelete(action = OnDeleteAction.CASCADE)
    @ManyToOne
    private Comment replyTo;

    @ManyToOne
    private User user;


    public Comment(){
    	
    }

	public Comment(String text, User user, Post post) {
		this.text = text;
		this.user = user;
		this.post = post;
	}

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

	public String getText() {
        return text;
    }

    public void setText(String text) {
        this.text = text;
    }

    public Post getPost() {
        return post;
    }

    public void setPost(Post post) {
        this.post = post;
    }

    public Comment getReplyTo(){
        return replyTo;
    }

    public void setReplyTo(Comment replyTo) {
        this.replyTo = replyTo;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }
}
