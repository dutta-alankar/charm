#ifndef _BLUE_TYPES_H_
#define _BLUE_TYPES_H_

/*****************************************************************************
   used internally, define minHeap of messages
   it use the msg time as key and dequeue the msg with the smallest time.
*****************************************************************************/

class minMsgHeap
{
private:
  char **h;
  int count;
  int size;
  void swap(int i, int j) {
    char * temp = h[i];
    h[i] = h[j];
    h[j] = temp;
  }
  
public:
  minMsgHeap() {
     size = 16;
     h = new char *[size];
     count = 0;
  }
  ~minMsgHeap() {
     delete [] h;
  }
  inline int length() const { return count; }
  inline int isEmpty() { return (count == 0); }
  void expand() {
    char **oldh = h;
    int oldcount = count;
    size *=2;
    h = new char *[size];
    count = 0;
    for (int i=0; i<oldcount; i++) enq(oldh[i]);
    delete [] oldh;
  }
  void enq(char *m) {
//CmiPrintf("enq %p\n", m);
      int current;

      if (count < size) {
        h[count] = m;
        current = count;
        count++;
      } else {
        expand();
        enq(m);
        return;
      }

      int parent = (current - 1)/2;
      while (current != 0)
        {
          if (CmiBgMsgRecvTime(h[current]) < CmiBgMsgRecvTime(h[parent]))
            {
              swap(current, parent);
              current = parent;
              parent = (current-1)/2;
            }
          else
            break;
        }
  }

  char *deq() {
//CmiPrintf("deq \n");
    if (count == 0) return 0;

    char *tmp = h[0];
    int best;

    h[0] = h[count-1];
    count--;

    int current = 0;
    int c1 = 1; int c2 = 2;
    while (c1 < count)
    {
      if (c2 >= count)
	best = c1;
      else
	{
	  if (CmiBgMsgRecvTime(h[c1]) < CmiBgMsgRecvTime(h[c2]))
	    best = c1;
	  else
	    best = c2;
	}
      if (CmiBgMsgRecvTime(h[best]) < CmiBgMsgRecvTime(h[current]))
	{
	  swap(best, current);
	  current = best;
	  c1 = 2*current + 1;
	  c2 = c1 + 1;
	}
      else
	break;
    }
    return tmp;
  }
  char * operator[](size_t n)
  {
//CmiPrintf("[] %d\n", n);
    return h[n];
  }
  int least(int a, int b, int c){
    int small;

    //if(h[a]->key() < h[b]->key())
      if(CmiBgMsgRecvTime(h[a])<CmiBgMsgRecvTime(h[b]))
      small=a;
    else
      small=b;
    
      //if(h[small]->key()<h[c]->key())
      if(CmiBgMsgRecvTime(h[small])<CmiBgMsgRecvTime(h[c]))
      return small;
    else
      return c;
  }

  //Value of item at index has changed, update heap
  void update(int index){
    
    int parent = (index-1)/2;
   
    //if((index != 0) && (h[parent]->key() > h[index]->key())){
      if((index != 0) && (CmiBgMsgRecvTime(h[index])<CmiBgMsgRecvTime(h[parent]))) {
      swap(parent,index);
      update(parent);
    }
    
    int c1 = 2*index+1;
    int c2 = 2*index+2;

    if(c2<length()){
      int small = least(index,c1,c2);
      if(small != index){
   	swap(small,index);
	update(small);
	return;
      }
    }
    //if(c1<length() && (h[index]->key() > h[c1]->key())){
         if(c1<length() && (CmiBgMsgRecvTime(h[c1])<CmiBgMsgRecvTime(h[index]))){
      swap(c1,index);
      update(c1);
      return;
    }    
  }

};

template <class T>
class minHeap
{
private:
  T *h;
  int count;
  int size;
  void swap(int i, int j) {
    T temp = h[i];
    h[i] = h[j];
    h[j] = temp;
  }
  
public:
  minHeap() {
     size = 16;
     h = new T [size];
     count = 0;
  }
  minHeap(int atleast){
    size = (atleast>16?atleast:16);
    h = new T [size];
    count = 0;
  }
  ~minHeap() {
     delete [] h;
  }
  inline int length() const { return count; }
  inline int isEmpty() { return (count == 0); }
  void expand() {
    T *oldh = h;
    int oldcount = count;
    size *=2;
    h = new T[size];
    count = 0;
    for (int i=0; i<oldcount; i++) enq(oldh[i]);
    delete [] oldh;
  }

  int least(int a, int b, int c){
    int small;

    //if(h[a]->key() < h[b]->key())
      if(h[a]->compareKey(h[b])==-1)
      small=a;
    else
      small=b;
    
      //if(h[small]->key()<h[c]->key())
      if(h[small]->compareKey(h[c])==-1)
      return small;
    else
      return c;
  }

  void print(){
    CmiPrintf("---Heap start--\n");
    for(int i=0;i<length();i++)
      CmiPrintf("%e\t",h[i]->key());
    CmiPrintf("---Heap end--\n\n");
  }

  //Value of item at index has changed, update heap
  void update(int index){
    
    int parent = (index-1)/2;
   
    //if((index != 0) && (h[parent]->key() > h[index]->key())){
      if((index != 0) && (h[index]->compareKey(h[parent])==-1)){
      swap(parent,index);
      update(parent);
    }
    
    int c1 = 2*index+1;
    int c2 = 2*index+2;

    if(c2<length()){
      int small = least(index,c1,c2);
      if(small != index){
   	swap(small,index);
	update(small);
	return;
      }
    }
    //if(c1<length() && (h[index]->key() > h[c1]->key())){
         if(c1<length() && (h[c1]->compareKey(h[index]))==-1){
      swap(c1,index);
      update(c1);
      return;
    }    
  }

  void add(T m) {
      if (count < size) {
        h[count] = m;
        count++;
      } else {
        expand();
        add(m);
      }
  }

  void enq(T m) {
//CmiPrintf("enq %p\n", m);
      int current;

      if (count < size) {
        h[count] = m;
        current = count;
        count++;
      } else {
        expand();
        enq(m);
        return;
      }

      int parent = (current - 1)/2;
      while (current != 0)
        {
	  //if (h[current]->key() < h[parent]->key())
	  if(h[current]->compareKey(h[parent]) == -1)
            {
              swap(current, parent);
              current = parent;
              parent = (current-1)/2;
            }
          else
            break;
        }
  }

  T deq() {
//CmiPrintf("deq \n");
    if (count == 0) return 0;

    T tmp = h[0];
    int best;

    h[0] = h[count-1];
    count--;

    int current = 0;
    int c1 = 1; int c2 = 2;
    while (c1 < count)
    {
      if (c2 >= count)
	best = c1;
      else
	{
	  // if (h[c1]->key() < h[c2]->key())
	  if(h[c1]->compareKey(h[c2])==-1)
	    best = c1;
	  else
	    best = c2;
	}
      //if (h[best]->key() < h[current]->key())
      if(h[best]->compareKey(h[current])==-1)
	{
	  swap(best, current);
	  current = best;
	  c1 = 2*current + 1;
	  c2 = c1 + 1;
	}
      else
	break;
    }
    return tmp;
  }
  T operator[](size_t n)
  {
//CmiPrintf("[] %d\n", n);
    return h[n];
  }
  void buildHeap() {
    for (int i=count/2-1; i>=0; i--) update(i);
  }
  void integrityCheck(int index) {
    int c1 = 2*index+1;
    int c2 = 2*index+2;
    if (c2 < count) {
      CmiAssert(h[index]->compareKey(h[c2])==-1);
      integrityCheck(c2);
    }
    if (c1 < count) {
      CmiAssert(h[index]->compareKey(h[c1])==-1);
      integrityCheck(c1);
    }
  }
};


template<class T> class bgQueue;


#endif


