---
title: LeetCode
date: 2018-06-17 15:03:29
tags:
---


### 1 两数之和

题目：

给定一个整数数列，找出其中和为特定值的那两个数。

你可以假设每个输入都只会有一种答案，同样的元素不能被重用。

示例:

给定 nums = [2, 7, 11, 15], target = 9

因为 nums[0] + nums[1] = 2 + 7 = 9
所以返回 [0, 1]

答案：
通过以空间换取速度的方式，我们可以将查找时间从 
O(n) 降低到 O(1)。哈希表正是为此目的而构建的，它支持以 近似 恒定的时间进行快速查找。我用“近似”来描述，是因为一旦出现冲突，查找用时可能会退化到 O(n)。但只要你仔细地挑选哈希函数，在哈希表中进行查找的用时应当被摊销为 O(1)。

```
class Solution {
    func twoSum(_ nums: [Int], _ target: Int) -> [Int] {
        var valKeyMap: Dictionary<Int, Int> = Dictionary<Int, Int>()
        
        for (idx,val) in nums.enumerated() {
            let other_target = target - val
            if let ot = valKeyMap[other_target] {
                if ot != idx {
                    return [idx,ot]
                }
            }
            valKeyMap[val] = idx
        }
        
        return []
    }
}

Solution().twoSum([1,2,4,5], 9)

```


### 2 两数相加

给定两个非空链表来表示两个非负整数。位数按照逆序方式存储，它们的每个节点只存储单个数字。将两数相加返回一个新的链表。

你可以假设除了数字 0 之外，这两个数字都不会以零开头。

示例：

输入：(2 -> 4 -> 3) + (5 -> 6 -> 4)
输出：7 -> 0 -> 8
原因：342 + 465 = 807


```
public class ListNode {
    public var val: Int
    public var next: ListNode?
    public init(_ val: Int) {
        self.val = val
        self.next = nil
    }
}

class Solution {
    
    func addTwoNumbers(_ l1: ListNode?, _ l2: ListNode?) -> ListNode? {

        var outCarrer = l1?.next
        var outCarrer2 = l2?.next
        
        var lasttenths = 0
        let sum = l1!.val + l2!.val
        if sum > 9 {
            lasttenths = 1
        }
        let newList:ListNode? = ListNode(sum % 10)
        var inCarrer = newList
        
        while outCarrer != nil || outCarrer2 != nil{
            
            var val1 = 0
            var val2 = 0
            
            if let v = outCarrer?.val {
                val1 = v
            }
            if let v = outCarrer2?.val {
                val2 = v
            }
            
            let sum = val1 + val2 + lasttenths
            lasttenths = sum > 9 ? 1 : 0
            let sum2 = sum % 10
            inCarrer?.next = ListNode(sum2)
            outCarrer = outCarrer?.next
            outCarrer2 = outCarrer2?.next
            inCarrer = inCarrer?.next
        }
        
        if lasttenths != 0{
            inCarrer?.next = ListNode(1)
        }
        return newList
    }
}
```

### 3. 无重复字符的最长子串

给定一个字符串，找出不含有重复字符的最长子串的长度。

示例：

给定 "abcabcbb" ，没有重复字符的最长子串是 "abc" ，那么长度就是3。

给定 "bbbbb" ，最长的子串就是 "b" ，长度是1。

给定 "pwwkew" ，最长子串是 "wke" ，长度是3。请注意答案必须是一个子串，"pwke" 是 子序列  而不是子串。

方法1

```
public class Solution {
    public int lengthOfLongestSubstring(String s) {
        int n = s.length();
        int ans = 0;
        for (int i = 0; i < n; i++)
            for (int j = i + 1; j <= n; j++)
                if (allUnique(s, i, j)) ans = Math.max(ans, j - i);
        return ans;
    }

    public boolean allUnique(String s, int start, int end) {
        Set<Character> set = new HashSet<>();
        for (int i = start; i < end; i++) {
            Character ch = s.charAt(i);
            if (set.contains(ch)) return false;
            set.add(ch);
        }
        return true;
    }
}
```

方法2

```
public class Solution {
    public int lengthOfLongestSubstring(String s) {
        int n = s.length();
        Set<Character> set = new HashSet<>();
        int ans = 0, i = 0, j = 0;
        while (i < n && j < n) {
            // try to extend the range [i, j]
            if (!set.contains(s.charAt(j))){
                set.add(s.charAt(j++));
                ans = Math.max(ans, j - i);
            }
            else {
                set.remove(s.charAt(i++));
            }
        }
        return ans;
    }
}
```

方法3 

```
public class Solution {
    public int lengthOfLongestSubstring(String s) {
        int n = s.length(), ans = 0;
        Map<Character, Integer> map = new HashMap<>(); // current index of character
        // try to extend the range [i, j]
        for (int j = 0, i = 0; j < n; j++) {
            if (map.containsKey(s.charAt(j))) {
                i = Math.max(map.get(s.charAt(j)), i);
            }
            ans = Math.max(ans, j - i + 1);
            map.put(s.charAt(j), j + 1);
        }
        return ans;
    }
}
```

### 78. 子集

给定一组不含重复元素的整数数组 nums，返回该数组所有可能的子集（幂集）。

说明：解集不能包含重复的子集。