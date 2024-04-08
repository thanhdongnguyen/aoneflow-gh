#!/bin/bash

# Đường dẫn tới file cấu hình
CONFIG_FILE="$HOME/.gh/conf.conf"
CURRENT_DIR="$(pwd)"

# Hàm hiển thị trợ giúp
show_help() {
  printf "Các câu lệnh có thể thực hiện được với gh:\n"
  printf " - gh help: tìm sự trợ giúp\n"
  printf " - gh feature xxx: tạo 1 tính năng mới với branch feature\n"
  printf " - gh hotfix xxx: tạo branch để hotfix\n"
  printf " - gh release xxx: resolve conflict từ master\n"
  printf " - gh testing xxx: resolve conflict từ develop\n"
  printf " - gh finish: Kết thúc\n"
  printf " - gh setup: cấu hình sử dụng\n"
}

# Hàm setup cấu hình
setup_config() {
  read -p "Nhập tên người sử dụng: " username
  mkdir -p "$(dirname "$CONFIG_FILE")"

  read -p "Nhập tên branch (main/master): " main_branch
  mkdir -p "$(dirname "$CONFIG_FILE")"

  read -p "Nhập tên branch dev (dev/develop): " dev_branch
  mkdir -p "$(dirname "$CONFIG_FILE")"

  echo "username=$username" > "$CONFIG_FILE"
  echo "main_branch=$main_branch" >> "$CONFIG_FILE"
  echo "dev_branch=$dev_branch" >> "$CONFIG_FILE"

  printf "Cấu hình đã được lưu.\n"
}

# Hàm lấy username từ file cấu hình
get_username() {
  if [[ ! -f "$CONFIG_FILE" ]]; then
    printf "Bạn chưa cấu hình. Hãy chạy gh setup trước.\n" >&2
    return 1
  fi
  source "$CONFIG_FILE"
  echo "$username"
}

get_main_branch() {
  if [[ ! -f "$CONFIG_FILE" ]]; then
    printf "Bạn chưa cấu hình. Hãy chạy gh setup trước.\n" >&2
    return 1
  fi
  source "$CONFIG_FILE"
  echo "$main_branch"
}

get_dev_branch() {
  if [[ ! -f "$CONFIG_FILE" ]]; then
    printf "Bạn chưa cấu hình. Hãy chạy gh setup trước.\n" >&2
    return 1
  fi
  source "$CONFIG_FILE"
  echo "$dev_branch"
}



# Hàm thực hiện các công việc git
git_operation() {
  local operation=$1
  local task_name=$2
  local merge_branch=$3

  

  local username=$(get_username)
  if [[ $? -ne 0 ]]; then
    return 1
  fi

  local main_branch=$(get_main_branch)
  if [[ $? -ne 0 ]]; then
    return 1
  fi

  local dev_branch=$(get_dev_branch)
  if [[ $? -ne 0 ]]; then
    return 1
  fi

  
  git commit -a -m "task_${task_name}: Save commit"
  case "$operation" in
    feature|hotfix|release)
      if [[ -z "$task_name" ]]; then
        printf "Tên branch không được để trống.\n" >&2
        return 1
      fi
      git checkout $main_branch
      git pull
      local new_branch="${operation}_${username}/task_${task_name}"
      git checkout -b "$new_branch"
      if [[ -n "$merge_branch" ]]; then
        git merge "$merge_branch" --no-ff -m "Merge $merge_branch into $new_branch"
      fi
      ;; 
    testing)
      if [[ -z "$task_name" ]]; then
        printf "Tên branch không được để trống.\n" >&2
        return 1
      fi
      git checkout $dev_branch
      git pull
      local new_branch="${operation}_${username}/task_${task_name}"
      git checkout -b "$new_branch"
      if [[ -n "$merge_branch" ]]; then
        git merge "$merge_branch" --no-ff -m "Merge $merge_branch into $new_branch"
      fi
      ;;
    finish)
      git add ${CURRENT_DIR}
      git commit -a -m "task_${task_name}: Save commit"
      local current_branch=$(git branch --show-current)
      git push origin "$current_branch"
      ;;
    *)
      printf "Thao tác không được hỗ trợ.\n" >&2
      return 1
      ;;
  esac
}

# Xử lý dòng lệnh
case "$1" in
  help)
    show_help
    ;;
  setup)
    setup_config
    ;;
  username)
    get_username
    ;;
  feature|hotfix|release|testing|finish)
    git_operation "$1" "$2" "$3"
    ;;
  *)
    show_help
    ;;
esac
