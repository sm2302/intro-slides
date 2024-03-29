library(tidyverse)

# Source code from https://github.com/johnistan/ulam-spirals-R

Ulam.Spiral<-function(N){
  if (N %% 2 == 0){
    cat(sprintf("Error: function only accepts odd integers because it a poorly written and fragile piece of code.\n"))
  }else{
    m <- matrix(NA, nrow=(N), ncol=N)
    top.left<-c(1,1)
    bottom.right<-c(N,N)
    top.right<-c(1,N)
    bottom.left<-c(N,1)
    n<-N
    a<-N
    m[median(1:N),median(1:N)]<-1
    
    while(a>=3){
      # This is an adaptation of a Euler Problem 28 solution. It calculates the diaginals. 
      m[bottom.right[1],bottom.right[2]]<- a^2 #bottom right
      m[top.left[1],top.left[2]]<- a^2 - 2*a + 2 # top left
      m[top.right[1],top.right[2]]<- a^2 - 3*a + 3 # top right
      m[bottom.left[1],bottom.left[2]]<- a^2 - a + 1 #bottom left
      
      #Both Horizontal Rows
      m[top.left[1],(top.left[2]+1):(top.right[2]-1)]<-seq( m[top.left[1],top.left[2]]-1,m[top.left[1],top.right[2]]+1) #Fill in top row
      m[bottom.left[1],(bottom.left[2]+1):(bottom.right[2]-1)]<-seq(m[bottom.left[1],bottom.left[2]]+1,  m[bottom.left[1],bottom.right[2]]-1) #Fill in bottom row
      #Left Vertical Rows
      m[(top.left[1]+1):(bottom.left[1]-1), top.left[1]] <- seq(m[top.left[1],top.left[1]]+1,  m[bottom.left[1],top.left[1]]-1)#Left Hand Row
      #Right Verical Row
      m[(top.right[1]+1):(bottom.right[2]-1),top.right[2]] <-seq(m[top.right[1],top.right[2]]-1 , m[top.right[1],top.right[2]] - (a-2) )
      #drop down on square  and repeat
      a<-a-2
      top.left<-c(top.left[1]+1,top.left[2]+1)
      bottom.right<-c(bottom.right[1]-1,bottom.right[2]-1)
      top.right<-c(top.right[1]+1,top.right[2]-1)
      bottom.left<-c(bottom.left[1]-1,bottom.left[2]+1)
    }
    return(m)   
  }
}

Prime.Marker<-function(N, ulamSpiral){
  m <- matrix(NA, nrow=(N^2), ncol=4)
  for (i in seq(N)) {
    for(j in seq(N)){
      #    print(ulamSpiral[i,j])
      m[ulamSpiral[i,j],] <- c(ulamSpiral[i,j],j,i,IsPrime(ulamSpiral[i,j]))
    }
  }
  m <-as.data.frame(m)
  colnames(m)<-c("n","x","y","p")
  return(m)
}

#Prime Number Checker stolen from http://librestats.wordpress.com/2011/08/20/prime-testing-function-in-r/
#Thanks to librestats

IsPrime <- function(n){ # n=Integer you want to know if is/not prime
  if ((n-floor(n)) > 0){
    cat(sprintf("Error: function only accepts natural number inputs\n"))
  } else if (n < 1){
    cat(sprintf("Error: function only accepts natural number inputs\n"))
  } else
    # Prime list exists
    if (try(is.vector(primes), silent=TRUE) == TRUE){
      
      # Prime list is already big enough
      if (n %in% primes){
        TRUE
      } else
        if (n < tail(primes,1)){
          FALSE
        } else
          if (n <= (tail(primes,1))^2){
            flag <- 0
            for (prime in primes){
              if (n%%prime == 0){
                flag <- 1
                break
              }
            }
            
            if (flag == 0){
              TRUE
            }
            else {
              FALSE
            }
          }
      
      # Prime list is too small; get more primes
      else {
        last.known <- tail(primes,1)
        while ((last.known)^2 < n){
          assign("primes", c(primes,GetNextPrime(primes)), envir=.GlobalEnv)
          last.known <- tail(primes,1)
        }
        IsPrime(n)
      }
    } else {
      # Prime list does not exist
      assign("primes", PrimesBelow(n,below.sqrt=TRUE), envir=.GlobalEnv)
      IsPrime(n)
    }
}

# Get next prime
GetNextPrime <- function(primes){ # primes=Known prime list
  i <- tail(primes,1)
  while (TRUE){
    flag <- 0
    i <- i+2
    if (i%%6 == 3){
      flag <- 1
    }
    if (flag == 0){
      s <- sqrt(i)+1
      possible.primes <- primes[primes<s]
      for (prime in possible.primes){
        if ((i%%prime == 0)){
          flag <- 1
          break
        }
      }
      if (flag == 0){
        break
      }
    }
  }
  i
}

# Primes below specified integer n; optionally only those below sqrt(n)
PrimesBelow <- function(n, below.sqrt=FALSE){
  if (below.sqrt == TRUE){
    m <- ceiling(sqrt(n))
  } else {
    m <- n
  }
  
  primes <- c(2,3)
  i <- 3
  while (i < m-1){
    flag <- 0
    i <- i+2
    if (i%%6 == 3){
      flag <- 1
    }
    if (flag == 0){
      s <- sqrt(i)+1
      possible.primes <- primes[primes<s]
      for (prime in possible.primes){
        if ((i%%prime == 0)){
          flag <- 1
          break
        }
      }
      if (flag == 0){
        primes <- c(primes, i)
      }
    }
  }
  primes
}

# Plot small Ulam spiral -------------------------------------------------------
N <- 5
dat <- Prime.Marker(N, Ulam.Spiral(N))
ggplot(dat, aes(x, y, fill = p, label = n)) +
  geom_tile(stat = "identity") +
  geom_text(aes(col = p), size = 5) +
  coord_equal() +
  scale_fill_viridis_c(option = "magma", begin = 0.15, end = 0.95, 
                       direction = -1) +
  scale_colour_viridis_c(option = "magma", begin = 0.15, end = 0.95) +
  theme_void() +
  theme(legend.position = "none")

# Plot a bigger one ------------------------------------------------------------
# Almost same code, just change N. For slides I used N = 501
N <- 251
dat <- Prime.Marker(N, Ulam.Spiral(N))
ggplot(dat, aes(x, y, fill = p, label = n)) +
  geom_tile(stat = "identity") +
  coord_equal() +
  scale_fill_viridis_c(option = "magma", begin = 0.15, end = 0.95, 
                       direction = -1) +
  theme_void() +
  theme(legend.position = "none") + 
  ggtitle("Ulam spiral") -> p1

# What if the primes are randomly scattered? -----------------------------------
dat %>%
  mutate(p = sample(c(0, 1), size = nrow(dat), replace = TRUE,
                    prob = c(1 - mean(dat$p), mean(dat$p)))) %>%
  ggplot(aes(x, y, fill = p, label = n)) +
  geom_tile(stat = "identity") +
  coord_equal() +
  scale_fill_viridis_c(option = "magma", begin = 0.15, end = 0.95, 
                       direction = -1) +
  theme_void() +
  theme(legend.position = "none") +
  ggtitle("Random points") -> p2

# Save the plot ----------------------------------------------------------------
ggsave(cowplot::plot_grid(p1, p2), filename = "spiral_random.png")
