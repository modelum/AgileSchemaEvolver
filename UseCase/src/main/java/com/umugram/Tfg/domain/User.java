package com.umugram.Tfg.domain;

import jakarta.persistence.*;

import java.io.Serial;
import java.io.Serializable;
import java.time.LocalDate;
import java.util.*;

@Entity
@NamedEntityGraphs(
        @NamedEntityGraph(
                name = "uploadPosts",
                attributeNodes = @NamedAttributeNode("userPosts")
        )

)
public class User implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

	@Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(unique = true, nullable = false)
    private String username;
    
    @Column(nullable = false)
    private String email;
    
    @Column(nullable = false)
    private String password;
    
    @Column(nullable = false)
    @Temporal(TemporalType.DATE)
    private LocalDate birthday;

    @Embedded
    private Profile profile;

    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(
            name = "FOLLOWER_RELATIONSHIPS",
            joinColumns = @JoinColumn(name = "USER"),
            inverseJoinColumns = @JoinColumn(name = "FOLLOWED")
    )
    private final Set<User> followers;

    @ManyToMany(mappedBy = "followers", fetch = FetchType.EAGER)
    private final Set<User> following;

    @OneToMany(mappedBy = "user", orphanRemoval = true, fetch = FetchType.EAGER)
    private final List<Comment> userComments;

    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.EAGER)
    private final List<Post> userPosts;

    public User(){
        this.followers = new HashSet<User>();
        this.following = new HashSet<User>();
        this.userComments = new LinkedList<Comment>();
        this.userPosts = new LinkedList<Post>();
    }

    public User(String username, String password, LocalDate birthday, String email) {
        this();
        this.username = username;
		this.password = password;
		this.birthday = birthday;
		this.email = email;
	}
    
	public Long getId() {
		return id;
	}

	public void setId(Long id) {
        this.id = id;
    }

	public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getEmail() {
        return email; 
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public LocalDate getBirthday() {
        return birthday;
    }

    public void setBirthday(LocalDate birthday) {
        this.birthday = birthday;
    }

    public Profile getProfile() {
        return profile;
    }

    public void setProfile(Profile profile) {
        this.profile = profile;
    }

    public Set<User> getFollowers()
    {
        return Collections.unmodifiableSet(followers);
    }

    public void addFollowers(User...followers)
    {
    	 for (User user : followers) {
	        if (!this.followers.contains(user)) {
	            this.followers.add(user);
	            user.addUsersFollowing(this);
	        }
    	 }
    }

    public Set<User> getUsersFollowing()
    {
        return Collections.unmodifiableSet(following);
    }

    public void addUsersFollowing(User...following)
    {
    	for (User user : following) {
            if (!this.following.contains(user)) {
                this.following.add(user);
                user.addFollowers(this);
            }
        }
    }

    public void removeFollower(User user)
    {
        if (this.followers.contains(user)) {
            this.followers.remove(user);
            user.removeUserFollowing(this);
        }
    }

    public void removeUserFollowing(User user)
    {
        if (this.following.contains(user)) {
            this.following.remove(user);
            user.removeFollower(this);
        }
    }

    public List<Comment> getWrittenComments()
    {
        return Collections.unmodifiableList(userComments);
    }

    public void addWrittenComments(Comment...userComments)
    {
        Collections.addAll(this.userComments,userComments);
    }

    public List<Post> getPosts()
    {
        return Collections.unmodifiableList(userPosts);
    }

    public void uploadPosts(Post...userPosts){
        for(Post post : userPosts){
            this.userPosts.add(post);
            post.setUser(this);
        }
    }

    public void deletePost(Post post) {
    	this.userPosts.remove(post);
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof User user)) return false;
        return Objects.equals(username, user.username) && Objects.equals(email, user.email) && Objects.equals(password, user.password) && Objects.equals(birthday, user.birthday) && Objects.equals(profile, user.profile);
    }

    @Override
    public int hashCode() {
        return Objects.hash(username, email, password, birthday, profile);
    }

    @Override
    public String toString() {
        return "User{" +
                "id=" + id +
                ", username='" + username + '\'' +
                ", email='" + email + '\'' +
                '}';
    }
}

