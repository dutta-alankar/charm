/*****************************************************************************
 * $Source$
 * $Author$
 * $Date$
 * $Revision$
 *****************************************************************************/

#ifndef _CDep_H_
#define _CDep_H_

/**
 This class hides all the details of dependencies between
 when blocks and entries. It also contains the entry buffers
 and when triggers.
*/

#include <stddef.h> // for size_t
#include "CMsgBuffer.h"
#include "CWhenTrigger.h"
#include "TList.h"

class CDep {
   int numEntries, numWhens;
   TListCWhenTrigger **whens;
   TListCMsgBuffer **buffers;
   int *numWhenDepends;
   int *numEntryDepends;
   TListCMsgBuffer ***whenDepends;
   TListCWhenTrigger ***entryDepends;
 public:
   CDep(int ne, int nw) : numEntries(ne), numWhens(nw)
   {
     // initialize the internal data structures here
     whens = new TListCWhenTrigger *[numWhens];
     buffers = new TListCMsgBuffer *[numEntries];
     numWhenDepends = new int[numWhens];
     numEntryDepends = new int[numEntries];
     whenDepends = new TListCMsgBuffer **[numWhens];
     entryDepends = new TListCWhenTrigger **[numEntries];
     int i;
     for(i=0;i<numWhens;i++) {
       whens[i] = new TListCWhenTrigger();
       whenDepends[i] = new TListCMsgBuffer *[numEntries];
       numWhenDepends[i] = 0;
     }
     for(i=0;i<numEntries;i++) {
       buffers[i] = new TListCMsgBuffer();
       entryDepends[i] = new TListCWhenTrigger *[numWhens];
       numEntryDepends[i] = 0;
     }
   }

   // adds a dependency of whenID upon Entry
   // done only at initialization.
   void addDepends(int whenID, int entry) {
     whenDepends[whenID][numWhenDepends[whenID]++] = buffers[entry];
     entryDepends[entry][numEntryDepends[entry]++] = whens[whenID];
   }

   // register a trigger to be called with
   // with <nEntries> specified
   // in <entries> with corresponding <refnums>
   void Register(CWhenTrigger *trigger)
   {
     whens[trigger->whenID]->append(trigger);
   }

   // deregister trigger from all
   // the entries it is registered for
   void deRegister(CWhenTrigger *trigger)
   {
     whens[trigger->whenID]->remove(trigger);
   }

   // buffer a message for a specific entry point with a specified
   // reference number
   void bufferMessage(int entry, void *msg, int refnum)
   {
     CMsgBuffer *buf = new CMsgBuffer(entry, msg, refnum);
     buffers[entry]->append(buf);
   }

   // For a specified entry number and reference number,
   // get the registered trigger which satisfies dependency. 
   // If no trigger exists
   // for the given reference number, get the trigger registered for
   // ANY ref num. If that also doesnt exist, Return NULL
   CWhenTrigger *getTrigger(int entry, int refnum)
   {
     for(int i=0;i<numEntryDepends[entry];i++) {
       TListCWhenTrigger *wlist = entryDepends[entry][i];
       for(CWhenTrigger *elem=wlist->begin(); 
           !wlist->end(); 
           elem=wlist->next()) {
         if(elem==0)
           break;
         if(depSatisfied(elem)){
            deRegister(elem);
            return elem;
         }
       }
     }
     return 0;
   }


   // given the entry number and reference number,
   // get the buffered message, without removing it from
   // the list, NULL if no such message exists
   CMsgBuffer *getMessage(int entry, int refnum)
   {
     TListCMsgBuffer *list = buffers[entry];
     for(CMsgBuffer *elem=list->begin(); !list->end(); elem=list->next()) {
       if(elem==0)
         return 0;
       if(elem->refnum == refnum)
         return elem;
     }
     return 0;
   }

   // given the entry number,
   // get the buffered message, without removing it from
   // the list, NULL if no such message exists
   // note that this is the ANY case
   CMsgBuffer *getMessage(int entry)
   {
     return buffers[entry]->front();
   }

   // remove the given message from buffer
   void removeMessage(CMsgBuffer *msg)
   {
     TListCMsgBuffer *list = buffers[msg->entry];
     list->remove(msg);
   }

   // return 1 if all the dependeces for trigger are satisfied
   // return 0 otherwise
   int depSatisfied(CWhenTrigger *trigger)
   {
     int i;
     for(i=0;i<trigger->nEntries;i++) {
       if(!getMessage(trigger->entries[i], trigger->refnums[i]))
         return 0;
     }
     for(i=0;i<trigger->nAnyEntries;i++) {
       if(!getMessage(trigger->anyEntries[i]))
         return 0;
     }
     return 1;
   }
};
#endif
