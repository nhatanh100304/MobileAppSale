import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase/domain/entities/user_profile.dart';
import 'package:firebase/presentation/Bloc/bloc.dart';
import 'package:firebase/presentation/Bloc/bloc_event.dart';
import 'package:firebase/presentation/Bloc/bloc_state.dart';

class EditProfilePage extends StatefulWidget {
  final String? uid;

  const EditProfilePage({super.key, required this.uid});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.uid != null && widget.uid!.isNotEmpty) {
      context.read<AuthBloc>().add(LoadUserProfile(widget.uid!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chỉnh sửa hồ sơ"),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context), // Đóng trang
          ),
        ],
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is UserProfileUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is UserProfileLoaded) {
            // Cập nhật dữ liệu vào các controller
            emailController.text = state.userProfile.email ?? "";
            phoneController.text = state.userProfile.phoneNumber ?? "";
            addressController.text = state.userProfile.address ?? "";

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: "Email"),
                  ),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: "Số điện thoại"),
                  ),
                  TextField(
                    controller: addressController,
                    decoration: const InputDecoration(labelText: "Địa chỉ"),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          UserProfile updatedProfile = UserProfile(
                            uid: widget.uid ?? "", // ✅ Đảm bảo UID không null
                            email: emailController.text,
                            phoneNumber: phoneController.text,
                            address: addressController.text,
                            profilePicture: state.userProfile.profilePicture ?? "", // ✅ Tránh null
                          );

                          context.read<AuthBloc>().add(UpdateUserProfile(updatedProfile));
                        },
                        child: const Text("Lưu"),
                      ),
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context), // Quay lại mà không lưu
                        child: const Text("Hủy"),
                      ),
                    ],
                  ),
                ],
              ),
            );
          } else if (state is AuthFailure) {
            return Center(child: Text(state.error));
          }
          return const Center(child: Text("Không có dữ liệu hồ sơ."));
        },
      ),
    );
  }
}
