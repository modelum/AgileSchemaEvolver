package com.umugram.Tfg;

import com.umugram.Tfg.domain.*;
import com.umugram.Tfg.repositories.*;

import jakarta.transaction.Transactional;

import static org.junit.jupiter.api.Assertions.*;
import org.junit.jupiter.api.*;


import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.time.LocalDate;
import java.util.LinkedList;
import java.util.List;


@SpringBootTest(classes = TfgApplication.class)
public class PostRepositoryTests {

    @Autowired
    private PostRepository postRepository;

    @Autowired
    private UserRepository userRepository;

    private User manuel;

    @BeforeEach
    void init() {
        userRepository.deleteAll();
        postRepository.deleteAll();

        manuel = new User("Manuel1", "contraseña2", LocalDate.of(2003, 3, 4), "manuel1@gmail.com");
        Profile manuProfile = new Profile("El manueh");
        manuProfile.setDescription("I love ice scream in the morning");
        manuProfile.setWebsite("elmanueh.es");
        manuel.setProfile(manuProfile);

        userRepository.saveAndFlush(manuel);
    }

    @Test
    void addPost() {

        // Arrange
    	
        // Act
        Post post = new PhotoPost("Manuel's post","https://www.google.com");
        post.setDescription("This is a post of Manuel");
        manuel.uploadPosts(post);

        userRepository.saveAndFlush(manuel);
        // Assert
        List<Post> postsManuel = postRepository.findByUser(manuel);
        assertEquals(postsManuel.size(),1);
    }
    
    

    @Test
    @Transactional
    void deletePost()
    {
        // Arrange
        Post post = new PhotoPost("Manuel's post","https://www.google.com");
        post.setDescription("This is a post of Manuel");
        manuel.uploadPosts(post);
        postRepository.saveAndFlush(post);
        userRepository.saveAndFlush(manuel);
        
        List<Post> postsManuel = postRepository.findByUser(manuel);
        assertEquals(postsManuel.size(),1);

        // Act
        manuel.deletePost(post);
        userRepository.saveAndFlush(manuel); 

        // Assert
        postsManuel = postRepository.findByUser(manuel);
        assertEquals(postsManuel.size(),0);
    }

    @Test
    @Transactional
    void deleteUserWithPosts()
    {
        // Arrange
        Post post = new PhotoPost("Manuel's post","https://www.google.com");
        post.setDescription("This is a post of Manuel");
        post = postRepository.save(post);
        manuel.uploadPosts(post);
        userRepository.saveAndFlush(manuel);

        List<Post> manuelPosts = postRepository.findByUser(manuel);
        assertEquals(manuelPosts.size(), 1);

        // Act
        userRepository.delete(manuel);

        // Assert
        manuelPosts = postRepository.findByUser(manuel);
        assertEquals(manuelPosts.size(), 0);
    }
    
}
