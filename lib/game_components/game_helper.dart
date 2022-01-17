class GameHelper {
  static int? nearestUnansweredIndex(int fromIndex, Set<int> answered, int n) {
    int left = fromIndex;
    int right = fromIndex;

    while (left >= 0 && right <= n) {
      if(!answered.contains(right)){
        return right;
      } else if(!answered.contains(left)) {
        return left;
      }
      left--;
      right++;
    }

    while(left >= 0) {
      if(!answered.contains(left)) {
        return left;
      }
      left--;
    }

    while(right <= n) {
      if(!answered.contains(right)){
        return right;
      }
      right++;
    }
    return null;
  }
}