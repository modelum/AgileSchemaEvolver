package com.umugram.Tfg.example;

import com.umugram.Tfg.domain.PhotoPost;
import com.umugram.Tfg.domain.Post;
import com.umugram.Tfg.domain.VideoPost;
import com.umugram.Tfg.repositories.PostRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;


import java.util.List;

@Component
public class Main implements CommandLineRunner
{

    @Autowired
    private PostRepository postRepository;

    @Override
    public void run(String... args) {
        postRepository.deleteAll();

        PhotoPost photoPost = new PhotoPost("https://www.google.com", "This is a photo post");
        postRepository.save(photoPost);

        VideoPost videoPost = new VideoPost("This is a video post","https://www.google.com", 60);
        postRepository.save(videoPost);

        List<Post> posts = postRepository.findAll();


        System.out.println("Posts:");
        for (Post post : posts) {
            System.out.println(post);
        }
    }
}