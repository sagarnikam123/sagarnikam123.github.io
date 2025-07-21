---
date: 2015-06-04 12:00:00 +0530
title: "How to download facebook photos in single shot ?"
description: "download all photos of a fan page using python script"
categories: [BigData,tips & tricks,Photography]
tags: [data,facebook,photos,download]
---

This article shows how to download all photos of a fan page using python script.
Script will download photos into folder named by fan page id.

------------------

**Prerequisite**
------------------

* Facebook Fanpage id
* Facebook access token ([Graph Explorer](https://developers.facebook.com/tools/explorer/ "Get access token from Facebook Graph explorer"))
* Python 2.7
* Python pip
* Facebook-python-sdk

------------------

### **Installing Python pip**
```shell
sudo apt-get install python-pip
```

--------------------

### **Installing facebook-sdk**
```shell
sudo pip install facebook-sdk
```

--------------------
If you unable to install facebook-python-sdk go to [installation page](http://facebook-sdk.readthedocs.org/en/latest/install.html)

---------------------

Change ``` ID ```  in script to your fan page.

---------------------

    #!/c/Python27/python

    import json
    import os
    import pickle
    import sys
    import time
    import urllib

    import facebook

    ID = 'SonalModakFotography'

    TOKEN = ''  # access token
    SAFE_CHARS = '-_() abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'

    def save(res, name='data'):
        """Save data to a file"""
        with open('%s.lst' % name, 'w') as f:
            pickle.dump(res, f)

    def read(name='data'):
        """Read data from a file"""
        with open('%s.lst' % name, 'r') as f:
            res = pickle.load(f)
        return res

    def fetch(limit=100000, depth=10, last=None, id=ID, token=TOKEN):
        """Fetch the data using Facebook's Graph API"""
        lst = []
        graph = facebook.GraphAPI(token)
        url = '%s/photos/uploaded' % id

        if not last:
            args = {'fields': ['source','name'], 'limit': limit}
            res = graph.request('%s/photos/uploaded' % id, args)
            process(lst, res['data'])
        else:
            res = {'paging': {'next': last}}

        # continue fetching till all photos are found
        for _ in xrange(depth):
            if 'paging' not in res:
                break
            try:
                url = res['paging']['next']
                res = json.loads(urllib.urlopen(url).read())
                process(lst, res['data'])
            except:
                break

        save(url, 'last_url')

        return lst

    def process(res, dat):
        """Extract required data from a row"""
        err = []
        for d in dat:
            if 'source' not in d:
                err.append(d)
                continue
            src = d['source']
            if 'name' in d:
                name = ''.join(c for c in d['name'][:99] if c in SAFE_CHARS) + src[-4:]
            else:
                name = src[src.rfind('/')+1:]
            res.append({'name': name, 'src': src})
        if err:
            print '%d errors.' % len(err)
            print err
        print '%d photos found.' % len(dat)

    def download(res):
        """Download the list of files"""
        start = time.clock()
        if not os.path.isdir(ID):
            os.mkdir(ID)
        os.chdir(ID)
        """ Using an counter to download 100 divisible photos & wait for some time  """
        delayCounter =1

        for p in res:
            # try to get a higher resolution of the photo
            p['src'] = p['src'].replace('_s', '_n')

            if delayCounter % 100 ==0 :
                #print "x - Downloaded %s picture " %delayCounter
                time.sleep(3)

            urllib.urlretrieve(p['src'], p['name'])
            #print delayCounter
            delayCounter = delayCounter + 1

        print "Downloaded %s pictures in %.3f sec." % (len(res), time.clock()-start)

    if __name__ == '__main__':
        # download 500 photos, fetch details about 100 at a time
        lst = fetch(limit=100000, depth=5000)
        save(lst, 'photos')
        download(lst)


-------------------------------

Save above script as ``` fbPhotos.py ``` & run as below.

```
python fbPhotos.py
```

-------------------------------
