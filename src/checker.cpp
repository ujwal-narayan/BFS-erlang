#include<bits/stdc++.h>
#define ll long long 
#define ld long double
#define X first
#define Y second
#define pb push_back
#define max_el(x) max_element(x.begin(),x.end())-x.begin()
#define min_el(x) min_element(x.begin(),x.end())-x.begin()
#define mp make_pair
#define endl '\n'
#define fastread ios_base::sync_with_stdio(false);cin.tie(NULL);cout.tie(NULL);
using namespace std;
// DONT USE MEMSET, USE VECTORS


vector<int> g[500001];
vector<int> order;
vector<int> vis;

int main(){
    int n,m;
    cin>>n>>m;
    //cerr<<n<<" "<<m<<endl;
    for(int i=0;i<m;i++){
        int u,v;
        cin>>u>>v;
        g[u].pb(v);
    }
    vis.resize(n);

    int u;
    set<int> uni;
    while(cin>>u){
        order.pb(u);
        uni.insert(u);
    }

    if(uni.size() != n){
        cerr<<"Size is "<<order.size()<<" not n="<<n<<endl;
        exit(1);
    }

    set<int> fron;
    
    for(int u:order){
        if(fron.size() == 0){
            fron.insert(u);
        }
        if(!fron.count(u)){
            cerr<<u<<" is incorrect in the ordering"<<endl;
            exit(1);
        }
        fron.erase(u);
        for(int v:g[u]){
            if(!vis[v]){
                fron.insert(v);
            }
        }
    }
    cerr<<"ok"<<endl;

    return 0;
}
